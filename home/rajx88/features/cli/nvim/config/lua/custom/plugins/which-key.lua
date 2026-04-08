return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    preset = "helix",
    spec = {
      {
        mode = { "n", "v" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>m", group = "markdown" },
        { "<leader>o", group = "obsidian" },
        { "<leader>q", group = "quit" },
        { "<leader>s", group = "search" },
        { "<leader>x", group = "diagnostics" },
        { "g", group = "goto" },
        { "]", group = "next" },
        { "[", group = "prev" },
      },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Keymaps",
    },
  },
}
