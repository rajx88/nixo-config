return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "ThePrimeagen/git-worktree.nvim",
  },
  keys = {
    { "<leader>sp", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>" },
    { "<leader>sP", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>" },
  },
  config = function()
    require("telescope").load_extension("git_worktree")
  end,
}
