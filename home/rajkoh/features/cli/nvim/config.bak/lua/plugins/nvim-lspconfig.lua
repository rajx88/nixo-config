local config = function()
  -- [[ Configure LSP ]]
  -- This function gets run when an LSP connects to a particular buffer.
  local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    vim.api.nvim_create_autocmd('BufWritePre', {
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end

  -- Setup neovim lua configuration
  require('neodev').setup()

  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  local lspconfig = require 'lspconfig'

  -- lua
  lspconfig.lua_ls.setup {
    capabilities = capabilities,
    settings = { -- custom settings for lua
      Lua = {
        -- make the language server recognize "vim" global
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          -- make language server aware of runtime files
          library = {
            [vim.fn.expand '$VIMRUNTIME/lua'] = true,
            [vim.fn.stdpath 'config' .. '/lua'] = true,
          },
        },
      },
    },
  }

  -- json
  lspconfig.jsonls.setup {
    capabilities = capabilities,
    filetypes = { 'json', 'jsonc' },
  }

  -- python
  lspconfig.pyright.setup {
    capabilities = capabilities,
    settings = {
      pyright = {
        disableOrganizeImports = false,
        analysis = {
          useLibraryCodeForTypes = true,
          autoSearchPaths = true,
          diagnosticMode = 'workspace',
          autoImportCompletions = true,
        },
      },
    },
  }

  -- typescript
  lspconfig.tsserver.setup {
    capabilities = capabilities,
    filetypes = {
      'typescript',
    },
    root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json', '.git'),
  }

  -- bash
  lspconfig.bashls.setup {
    capabilities = capabilities,
    filetypes = { 'sh', 'zsh', 'aliasrc' },
  }

  -- docker
  lspconfig.dockerls.setup {
    capabilities = capabilities,
  }

  local lspconfig = require 'lspconfig'

  local stylua = require 'efmls-configs.formatters.stylua'

  local eslint_d = require 'efmls-configs.linters.eslint_d'
  local prettier_d = require 'efmls-configs.formatters.prettier_d'
  local fixjson = require 'efmls-configs.formatters.fixjson'

  local hadolint = require 'efmls-configs.linters.hadolint'

  local shellcheck = require 'efmls-configs.linters.shellcheck'
  local shfmt = require 'efmls-configs.formatters.shfmt'

  local beautysh = require 'efmls-configs.formatters.beautysh'

  local golangci_lint = require 'efmls-configs.linters.golangci_lint'
  local gofmt = require 'efmls-configs.formatters.gofmt'

  local statix = require 'efmls-configs.linters.statix'
  local alejandra = require 'efmls-configs.formatters.alejandra'

  local ansible_lint = require 'efmls-configs.linters.ansible_lint'

  lspconfig.efm.setup {
    filetypes = {
      'lua',
      'go',
      'nix',
      'sh',
      'zsh',
      'yaml',
      'json',
      'jsonc',
      'markdown',
      'docker',
    },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
      hover = true,
      documentSymbol = true,
      codeAction = true,
      completion = true,
    },
    settings = {
      languages = {
        lua = { luacheck, stylua },
        sh = { shellcheck, shfmt },
        zsh = { beautysh },
        go = { goftmt, golangci_lint },
        python = { flake8, black },
        nix = { statix, alejandra },

        yaml = { prettier_d, ansible_lint },
        json = { eslint_d, fixjson },
        jsonc = { eslint_d, fixjson },
        markdown = { prettier_d },

        docker = { hadolint, prettier_d },

				typescript = { eslint, prettier_d },
				javascript = { eslint, prettier_d },
				javascriptreact = { eslint, prettier_d },
				typescriptreact = { eslint, prettier_d },

				html = { prettier_d },
				css = { prettier_d },
      },
    },
  }
end

return {
  -- NOTE: This is where your plugins related to LSP can be installed.
  -- The configuration is done below. Search for lspconfig to find it below.
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Useful status updates for LSP
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },

    -- Additional lua configuration, makes nvim stuff amazing!
    'folke/neodev.nvim',

    'creativenull/efmls-configs-nvim',
  },
  config = config,
}
