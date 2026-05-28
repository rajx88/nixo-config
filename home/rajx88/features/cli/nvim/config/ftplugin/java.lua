local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
local mason_share = vim.fn.stdpath("data") .. "/mason/share"

-- Lombok agent (mason bundles it with jdtls)
local lombok_jar = mason_share .. "/jdtls/lombok.jar"

-- DAP bundles: java-debug-adapter + java-test
local bundles = {}
local debug_jar = vim.fn.glob(mason_packages .. "/java-debug-adapter/com.microsoft.java.debug.plugin.jar", true)
if debug_jar ~= "" then
  table.insert(bundles, debug_jar)
end

local excluded_test_jars = {
  ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
  ["jacocoagent.jar"] = true,
}
for _, jar in ipairs(vim.split(vim.fn.glob(mason_packages .. "/java-test/*.jar", true), "\n")) do
  if jar ~= "" and not excluded_test_jars[vim.fn.fnamemodify(jar, ":t")] then
    table.insert(bundles, jar)
  end
end

-- Per-project workspace (persistent across reboots)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/eclipse/" .. project_name

local config = {
  name = "jdtls",
  cmd = {
    vim.fn.stdpath("data") .. "/mason/bin/jdtls",
    "--jvm-arg=-javaagent:" .. lombok_jar,
    "--jvm-arg=-Xms1g",
    "--jvm-arg=-Xmx8g",
    "-data",
    workspace_dir,
  },
  root_dir = vim.fs.root(0, {
    "gradlew",
    "mvnw",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  }),
  settings = {
    java = {
      -- Build config
      configuration = {
        updateBuildConfiguration = "automatic",
        -- Uncomment and adjust if you have multiple JDKs:
        -- runtimes = {
        --   { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk/" },
        --   { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk/" },
        -- },
      },
      autobuild = { enabled = true },
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },

      -- Annotation processing (Lombok, MapStruct, etc.)
      import = {
        gradle = {
          enabled = true,
          wrapper = { enabled = true },
          annotationProcessing = { enabled = true },
        },
        maven = { enabled = true },
      },

      -- Inlay hints
      inlayHints = {
        parameterNames = {
          enabled = "literals", -- "none" | "literals" | "all"
        },
      },

      -- Code lens
      referencesCodeLens = { enabled = true },
      implementationsCodeLens = { enabled = true },

      -- Signature help
      signatureHelp = {
        enabled = true,
        description = { enabled = true },
      },

      -- Completion
      completion = {
        enabled = true,
        guessMethodArguments = "insertParameterNames",
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.junit.Assert.*",
          "org.junit.Assume.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.jupiter.api.Assumptions.*",
          "org.junit.jupiter.api.DynamicContainer.*",
          "org.junit.jupiter.api.DynamicTest.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
        },
        importOrder = { "java", "javax", "jakarta", "com", "org" },
        filteredTypes = { "com.sun.*", "sun.*", "jdk.*" },
        overwrite = true,
        postfix = { enabled = true },
      },

      -- Sources
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      saveActions = {
        organizeImports = false,
      },

      -- References + decompiler
      references = {
        includeAccessors = true,
        includeDecompiledSources = true,
      },
      contentProvider = { preferred = "fernflower" },

      -- Format (disabled -- using google-java-format via conform)
      format = { enabled = false },

      -- Null analysis
      compile = {
        nullAnalysis = {
          mode = "automatic",
          nonnull = {
            "javax.annotation.Nonnull",
            "org.springframework.lang.NonNull",
          },
          nullable = {
            "javax.annotation.Nullable",
            "org.springframework.lang.Nullable",
          },
        },
      },

      -- Code generation
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },

      -- Misc
      errors = {
        incompleteClasspath = { severity = "warning" },
      },
      edit = {
        smartSemicolonDetection = { enabled = true },
      },
      jdt = {
        ls = {
          protobufSupport = { enabled = true },
        },
      },
    },
  },
  init_options = {
    bundles = bundles,
    extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
  },
  on_attach = function(_, bufnr)
    -- Wire up DAP support
    require("jdtls").setup_dap({ hotcodereplace = "auto" })

    -- Enable inlay hints
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

    -- Java-specific keymaps
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "<A-o>", require("jdtls").organize_imports, "Organize Imports")
    map("n", "crv", require("jdtls").extract_variable, "Extract Variable")
    map("v", "crv", function() require("jdtls").extract_variable(true) end, "Extract Variable")
    map("n", "crc", require("jdtls").extract_constant, "Extract Constant")
    map("v", "crm", function() require("jdtls").extract_method(true) end, "Extract Method")
    map("n", "<leader>dt", require("jdtls").test_class, "Debug Test Class")
    map("n", "<leader>dm", require("jdtls").test_nearest_method, "Debug Nearest Method")
  end,
}

require("jdtls").start_or_attach(config)
