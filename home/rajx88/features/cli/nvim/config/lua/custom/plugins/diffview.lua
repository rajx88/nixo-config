return {
  "sindrets/diffview.nvim",

  keys = {
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
  },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },

  config = function()
    require("diffview").setup()
  end,
}
