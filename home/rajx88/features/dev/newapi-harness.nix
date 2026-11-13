{
  config,
  lib,
  ...
}:
let
  # The switchyard provider is the local routing path; the newapi provider is
  # a direct new-api path using the dedicated harness key. Both are generated
  # here so switchyard.nix can stay focused on the router itself.
  port = 4123;
  contextWindow = 400000;
  maxOutput = 32000;

  harnessModels = [
    {
      id = "github_copilot/claude-haiku-5.5";
      name = "Claude Haiku 5.5";
      contextWindow = 1000000;
      maxTokens = 128000;
    }
    {
      id = "github_copilot/claude-sonnet-5.5";
      name = "Claude Sonnet 5.5";
      contextWindow = 1000000;
      maxTokens = 128000;
    }
    {
      id = "github_copilot/claude-opus-5.5";
      name = "Claude Opus 5.5";
      contextWindow = 1000000;
      maxTokens = 128000;
    }
    {
      id = "github_copilot/gemini-4-carbon";
      name = "Gemini 4 Carbon";
      contextWindow = 1000000;
      maxTokens = 65536;
    }
    {
      id = "github_copilot/gemini-4-argon";
      name = "Gemini 4 Argon";
      contextWindow = 1000000;
      maxTokens = 65536;
    }
    {
      id = "github_copilot/grok-4.7";
      name = "Grok 4.7";
      contextWindow = 500000;
      maxTokens = 128000;
    }
    {
      id = "github_copilot/gpt-6-luna";
      name = "GPT-6 Luna";
      contextWindow = 1000000;
      maxTokens = 128000;
    }
    {
      id = "github_copilot/gpt-6-astra";
      name = "GPT-6 Astra";
      contextWindow = 1000000;
      maxTokens = 128000;
    }
    {
      id = "github_copilot/gpt-6.1-sol";
      name = "GPT-6.1 Sol";
      contextWindow = 1100000;
      maxTokens = 128000;
    }
    {
      id = "github_copilot/gpt-6.1-terra";
      name = "GPT-6.1 Terra";
      contextWindow = 1100000;
      maxTokens = 128000;
    }
  ];

  switchyardModels = [
    {
      id = "sy/claude-auto";
      name = "Switchyard auto (Haiku ↔ Sonnet)";
    }
    {
      id = "sy/claude-heavy";
      name = "Switchyard heavy (Sonnet ↔ Opus)";
    }
  ];
in
{
  # omp: anthropic-messages so omp sends a session id (needed for
  # capable_hold_turns), adaptive thinking so Claude accepts it.
  home.file.".omp/agent/models.yml".text = lib.generators.toYAML { } {
    providers.switchyard = {
      baseUrl = "http://127.0.0.1:${toString port}";
      api = "anthropic-messages";
      auth = "none";
      models = map (m: {
        inherit (m) id name;
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = contextWindow;
        maxTokens = maxOutput;
        thinking = {
          mode = "anthropic-adaptive";
          efforts = [
            "low"
            "medium"
            "high"
          ];
        };
      }) switchyardModels;
    };

    providers.newapi = {
      baseUrl = "https://newapi.rx88.ws";
      api = "anthropic-messages";
      apiKey = "!cat ${config.home.homeDirectory}/.local/share/newapi/harness-key";
      models = map (m: {
        inherit (m)
          id
          name
          contextWindow
          maxTokens
          ;
        reasoning = true;
        input = [
          "text"
          "image"
        ];
      }) harnessModels;
    };
  };

  # pi: same anthropic-messages endpoint as omp. The SDK appends /v1/messages,
  # so baseUrl has no /v1. Switchyard holds the real key; apiKey is a dummy.
  home.file.".pi/agent/models.json".text = builtins.toJSON {
    providers.switchyard = {
      baseUrl = "http://127.0.0.1:${toString port}";
      api = "anthropic-messages";
      apiKey = "switchyard-local";
      models = map (m: {
        inherit (m) id name;
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = contextWindow;
        maxTokens = maxOutput;
      }) switchyardModels;
    };

    providers.newapi = {
      baseUrl = "https://newapi.rx88.ws";
      api = "anthropic-messages";
      apiKey = "!cat ${config.home.homeDirectory}/.local/share/newapi/harness-key";
      models = map (m: {
        inherit (m)
          id
          name
          contextWindow
          maxTokens
          ;
        reasoning = true;
        input = [
          "text"
          "image"
        ];
      }) harnessModels;
    };
  };
}
