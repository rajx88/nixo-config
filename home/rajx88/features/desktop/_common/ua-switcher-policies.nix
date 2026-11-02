# "User-Agent Switcher and Manager" ({a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7} in
# Firefox-family browsers; bhchdcejhohfmigjafbampogmaanbfkg in Chromium-family)
# reads its central config from chrome.storage.managed:
#
#   - whitelist mode: the extension spoofs the UA ONLY on the listed Microsoft
#     domains (the environments that reject Linux clients); every other site
#     sees the real browser ident, which keeps tesla.com / PayPal bot-checks
#     from tripping on a spoofed, contradictory fingerprint.
#   - `json` is the bridge key its managed.js copies into the live config on
#     browser start (it requires a `json-guid` marker); Firefox validates
#     managed-storage values against the extension's own managed_schema, which
#     only allows `ua` and `json`, hence the stringified `json` payload.
#
# Imported by ./firefox.nix and ./zen.nix through programs.*.policies.
{ ... }:
let
  extId = "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}";

  ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0";
  whitelist = [
    "microsoft.com"
    "microsoftonline.com"
    "office.com"
    "microsoft365.com"
    "sharepoint.com"
    "cloud.microsoft"
  ];

  prefs = {
    inherit ua;
    mode = "whitelist";
    inherit whitelist;
    userAgentData = true;
    "json-guid" = "nix-managed-1";
  };
in
{
  uaSwitcherManagedPolicy = {
    "3rdparty"."Extensions".${extId} = {
      inherit ua;
      json = builtins.toJSON prefs;
    };
  };
}
