return {
  -- the colorscheme should be available when starting Neovim
  {
    "rose-pine/neovim",
    enabled = false,
    name = "rose-pine",
    config = function()
      -- vim.cmd [[ colorscheme rose-pine ]]
    end,
  },
  {
    "folke/tokyonight.nvim",
    -- enabled = false,
    lazy = true,
    name = "tokyonight",
    opts = { style = "night", transparent = true },
  },
  {
    "baliestri/aura-theme",
    enabled = false,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
      -- vim.cmd [[ set background=dark ]]
      -- vim.cmd [[ colorscheme aura-dark ]]
      -- vim.cmd [[ colorscheme aura-dark ]]
      -- vim.cmd [[ colorscheme aura-dark-soft-text ]]
      -- vim.cmd [[ colorscheme aura-soft-dark ]]
      -- vim.cmd [[ colorscheme aura-soft-dark-soft-text ]]
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
    config = function()
      -- vim.cmd [[ colorscheme kanagawa]]
      -- vim.cmd [[ colorscheme kanagawa-wave]]
      -- vim.cmd [[ colorscheme kanagawa-dragon]]
      -- vim.cmd [[ colorscheme kanagawa-lotus]]
    end,
  },
}
