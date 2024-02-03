return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()

        require("tokyonight").setup({
            -- use the night style
            style = "night",
            transparent = true,
          })

        -- settings colorscheme
        vim.cmd.colorscheme 'tokyonight'
      end,
  }