return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },

  keys = {
    { "<leader>dv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
    { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
  },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },

  config = function()
    require("diffview").setup()
  end,
}
