return {
  "hrsh7th/nvim-cmp",
  lazy = false,
  priority = 100,
  dependencies = {
    "onsails/lspkind.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    vim.opt.completeopt = { "menu", "menuone", "noselect" }

    -- loading in custom snippets
    for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/custom/snippets/*.lua", true)) do
      loadfile(ft_path)()
    end

    -- setting keymaps for jumping around snippets
    vim.keymap.set({ "i", "s" }, "<c-k>", function()
      return vim.snippet.active { direction = 1 } and vim.snippet.jump(1)
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<c-j>", function()
      return vim.snippet.active { direction = -1 } and vim.snippet.jump(-1)
    end, { silent = true })

    local cmp = require "cmp"
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    --local cmp_select = { behavior = cmp.SelectBehavior.Insert }

    cmp.setup {
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- For luasnip users.
        { name = "buffer" },
      },
      mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-y>"] = cmp.mapping.confirm { select = true },
        ["<C-Space>"] = cmp.mapping.complete(),
      },

      -- Enable luasnip to handle snippet expansion for nvim-cmp
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
    }
  end,
}
