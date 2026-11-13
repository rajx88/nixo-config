{
  pkgs,
  config,
  ...
}:
let
  # Handy's post-processing (transcribe_with_post_process, ctrl+shift+space)
  # speaks plain OpenAI chat completions against a fixed base URL, and its
  # HTTP headers are hardcoded (llm_client.rs: Bearer auth, a Handy user agent,
  # no extra headers allowed). OpenCode Go serves the same API but rejects any
  # request that does not carry `x-opencode-session`:
  #
  #   400 {"type":"error","error":{"type":"MissingSessionID"}}
  #
  # So Handy cannot talk to https://opencode.ai/inference/go directly (its
  # "Custom" provider only exposes the base URL). This shim is that missing
  # header: a localhost-only pass-through to the Go gateway that adds a stable
  # session id and the workspace token, and exposes only what Handy uses
  # (GET /v1/models for the model dropdown, POST /v1/chat/completions).
  #
  # Usage is billed to the Go subscription's allowance, not to credit:
  # responses come back with usage.opencode.billing_source = "go".
  port = 4125;
  tokenFile = "${config.home.homeDirectory}/.local/share/handy-postprocess/token";
  opencodeAuth = "${config.home.homeDirectory}/.local/share/opencode/auth.json";

  shimPy = pkgs.writeText "handy-postprocess.py" ''
    #!/usr/bin/env python3
    """Localhost shim: Handy's OpenAI-compatible post-processing -> OpenCode Go.

    Injects the x-opencode-session header Go requires plus the workspace token.
    Runs on 127.0.0.1 only; any local process can borrow the token through it.
    """
    import json
    import os
    import sys
    import urllib.error
    import urllib.request
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

    UPSTREAM = "https://opencode.ai/inference/go"
    # A stable id is what Go asks for: it routes and caches per session. Every
    # dictation is independent, so one id for the whole shim is enough.
    SESSION_ID = "ses_handy-postprocess"
    USER_AGENT = "Handy/1.0 (+https://github.com/cjpais/Handy)"
    TOKEN_FILE = os.environ["HANDY_POSTPROCESS_TOKEN_FILE"]
    # Fallback for a machine with no dedicated key: opencode's own Go credential.
    AUTH_FILE = os.environ.get("HANDY_POSTPROCESS_OPENCODE_AUTH", "")
    ALLOWED = {("GET", "/v1/models"), ("POST", "/v1/chat/completions")}


    def read_token():
        try:
            with open(TOKEN_FILE, encoding="utf-8") as handle:
                token = handle.read().strip()
            if token:
                return token
        except OSError:
            pass
        if not AUTH_FILE:
            return ""
        try:
            with open(AUTH_FILE, encoding="utf-8") as handle:
                creds = json.load(handle).get("opencode-go", {})
        except (OSError, ValueError):
            return ""
        return str(creds.get("key", "")).strip()


    class Handler(BaseHTTPRequestHandler):
        server_version = "handy-postprocess"
        protocol_version = "HTTP/1.1"

        def _reply(self, status, payload, content_type="application/json"):
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)

        def _error(self, status, message):
            self._reply(status, json.dumps({"error": {"message": message}}).encode())

        def _proxy(self, method):
            path = self.path.split("?", 1)[0]
            if (method, path) not in ALLOWED:
                return self._error(404, "shim: only GET /v1/models and POST /v1/chat/completions")
            token = read_token()
            if not token:
                return self._error(500, "shim: no token in the token file and no opencode credential")

            length = int(self.headers.get("Content-Length") or 0)
            request = urllib.request.Request(
                UPSTREAM + path,
                data=self.rfile.read(length) if length else None,
                method=method,
                headers={
                    "Authorization": "Bearer " + token,
                    "Content-Type": "application/json",
                    "User-Agent": USER_AGENT,
                    "x-opencode-session": SESSION_ID,
                },
            )
            try:
                with urllib.request.urlopen(request, timeout=120) as response:
                    status, payload = response.status, response.read()
                    content_type = response.headers.get("Content-Type", "application/json")
            except urllib.error.HTTPError as err:
                status, payload = err.code, err.read()
                content_type = err.headers.get("Content-Type", "application/json")
            except Exception as err:  # network/DNS/TLS: report, keep serving
                print("shim: upstream failed: %r" % (err,), file=sys.stderr)
                return self._error(502, "shim: upstream failed")
            print("shim: %s %s -> %d" % (method, path, status), file=sys.stderr)
            self._reply(status, payload, content_type)

        def do_GET(self):
            self._proxy("GET")

        def do_POST(self):
            self._proxy("POST")

        def log_message(self, fmt, *args):  # journald gets the one line above only
            pass


    def main():
        server = ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), Handler)
        server.daemon_threads = True
        print("shim: listening on 127.0.0.1:%s" % sys.argv[1], file=sys.stderr)
        server.serve_forever()


    if __name__ == "__main__":
        main()
  '';

  shim = pkgs.writeShellScript "handy-postprocess" ''
    set -euo pipefail
    exec ${pkgs.python3}/bin/python3 ${shimPy} "$@"
  '';
in
{
  systemd.user.services.handy-postprocess = {
    Unit = {
      Description = "Handy post-processing -> OpenCode Go shim (localhost)";
      After = [ "network-online.target" ];
      # The token lives behind the impermanence bind mount; without this the
      # service can start before the mount and miss the key until restarted.
      RequiresMountsFor = [
        (dirOf tokenFile)
        (dirOf opencodeAuth)
      ];
    };
    Service = {
      ExecStart = "${shim} ${toString port}";
      Environment = [
        "HANDY_POSTPROCESS_TOKEN_FILE=${tokenFile}"
        "HANDY_POSTPROCESS_OPENCODE_AUTH=${opencodeAuth}"
        # urllib falls back to OpenSSL's compiled-in paths without this.
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # The key is created by hand (a secret is not a Nix value):
  #   install -d -m700 ~/.local/share/handy-postprocess
  #   read -rsp 'Go token: ' T && printf '%s\n' "$T" > ~/.local/share/handy-postprocess/token && unset T
  #   chmod 600 ~/.local/share/handy-postprocess/token
  home.persistence."/persist".directories = [
    ".local/share/handy-postprocess"
  ];

  # Handy's Custom provider points at http://127.0.0.1:${toString port}/v1 (set in
  # its own store, which stays GUI-owned — see handy.nix).
}
