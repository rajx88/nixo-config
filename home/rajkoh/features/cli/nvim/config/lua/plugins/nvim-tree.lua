return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('nvim-tree').setup {
      filters = {
        dotfiles = false,
        custom = {},
      },
      vim.keymap.set('n', '<M-e>', ':NvimTreeToggle<cr>', { silent = true }),
    }
  end,
}
