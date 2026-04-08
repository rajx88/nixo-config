return {
  {
    -- Mason: tool installer (LSP servers, formatters, linters)
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "alejandra",
        "delve",
        "gofumpt",
        "goimports",
        "google-java-format",
        "java-debug-adapter",
        "java-test",
        "jsonnetfmt",
        "shfmt",
        "prettierd",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- Auto-install ensure_installed tools
      local mr = require "mason-registry"
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed or {}) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
  {
    -- Bridge between Mason and nvim-lspconfig (v2 API)
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "bashls",
        "gopls",
        "jdtls",
        "jsonls",
        "jsonnet_ls",
        "lua_ls",
        "nil_ls",
        "templ",
        "yamlls",
      },
      -- nvim-jdtls manages the jdtls lifecycle itself
      automatic_enable = {
        exclude = { "jdtls" },
      },
    },
  },
  {
    -- Main LSP Configuration (Neovim 0.12 native API)
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "b0o/SchemaStore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Inject blink.cmp capabilities into all LSP servers
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Per-server configuration using the Neovim 0.12 native API
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            analyses = {
              unusedparams = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = { disable = { "missing-fields" } },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })
    end,
  },
  {
    -- Lua LSP support for Neovim config editing
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
