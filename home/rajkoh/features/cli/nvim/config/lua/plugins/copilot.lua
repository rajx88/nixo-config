return {
  "github/copilot.vim",
  config = function()
    -- setting accept butting is done by nvim-cmp
    vim.keymap.set("i", "<C-a>", "copilot#Accept('<CR>')",
      { noremap = true, silent = true, expr = true, replace_keycodes = false })
    vim.keymap.set("i", "<C-j>", "copilot#Next()", { expr = true, silent = true })
    vim.keymap.set("i", "<C-k>", "copilot#Previous()", { expr = true, silent = true })
    vim.g.copilot_no_tab_map = true
  end
}
