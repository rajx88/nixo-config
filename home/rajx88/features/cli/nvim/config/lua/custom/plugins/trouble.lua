return {
  "folke/trouble.nvim",
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
    {
      "[t",
      "<cmd>TroubleNext<cr>",
      desc = "Next Trouble",
    },
    {
      "]t",
      "<cmd>TroublePrevious<cr>",
      desc = "Previous Trouble",
    },
  },
  -- specs = {
  --   "folke/snacks.nvim",
  --   opts = function(_, opts)
  --     return vim.tbl_deep_extend("force", opts or {}, {
  --       picker = {
  --         actions = require("trouble.sources.snacks").actions,
  --         win = {
  --           input = {
  --             keys = {
  --               ["<c-t>"] = {
  --                 "trouble_open",
  --                 mode = { "n", "i" },
  --               },
  --             },
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },
}
