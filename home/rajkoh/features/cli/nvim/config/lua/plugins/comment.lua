return {
  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    opts = {
      -- comments
      vim.api.nvim_set_keymap('n', '<C-_>', 'gcc', { noremap = false }),
      vim.api.nvim_set_keymap('v', '<C-_>', 'gcc', { noremap = false }),
      -- Indenting
      vim.keymap.set('v', '<', '<gv', { silent = true, noremap = true }),
      vim.keymap.set('v', '>', '>gv', { silent = true, noremap = true }),
    },
  },
}
