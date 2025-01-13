return {
  -- the colorscheme should be available when starting Neovim
  {
    "rose-pine/neovim",
    name = "rose-pine",
    -- config = function()
    --   vim.cmd [[colorscheme rose-pine]]
    -- end,
  },
  {
    "embark-theme/vim",
    name = "embark",
    config = function()
      -- vim.cmd.colorscheme "embark"
    end,
  },
  {
    "0xstepit/flow.nvim",
    lazy = false,
    priority = 1000,
    tag = "v2.0.1",
    opts = {
      -- Your configuration options here.
    },
    config = function(_, opts)
      require("flow").setup(opts)
      -- vim.cmd.colorscheme "flow"
    end,
  },
  {
    "maxmx03/fluoromachine.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local fm = require "fluoromachine"

      fm.setup {
        glow = false,
        theme = "fluoromachine",
        transparent = true,
      }

      vim.cmd.colorscheme "fluoromachine"
    end,
  },
  {
    "helbing/aura.nvim",
    name = "aura",
    config = function()
      -- vim.cmd.colorscheme "aura"
    end,
  },
}
