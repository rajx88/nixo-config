{
  config,
  lib,
  ...
}:
let
  # Direct new-api path for the coding-agent harnesses, using the dedicated
  # harness key so agent traffic has its own quota/limits upstream.
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
      id = "github_copilot/gemini-4-neon";
      name = "Gemini 4 Neon";
      contextWindow = 1048576;
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
in
{
  # omp: anthropic-messages so Claude accepts adaptive thinking.
  home.file.".omp/agent/models.yml".text = lib.generators.toYAML { } {
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
  # so baseUrl has no /v1.
  home.file.".pi/agent/models.json".text = builtins.toJSON {
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

  # harness-key lives here, so the directory has to survive impermanence.
  home.persistence."/persist".directories = [
    ".local/share/newapi"
  ];
}
