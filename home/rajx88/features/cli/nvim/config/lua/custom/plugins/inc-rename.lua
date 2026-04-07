return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  opts = {},
  keys = {
    {
      "grn",
      function()
        return ":" .. require("inc_rename").config.cmd_name .. " " .. vim.fn.expand "<cword>"
      end,
      expr = true,
      desc = "Rename (inc-rename)",
    },
  },
}
