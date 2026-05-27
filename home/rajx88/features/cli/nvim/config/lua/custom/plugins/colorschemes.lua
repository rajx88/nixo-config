return {
  {
    "daltonmenezes/aura-theme",
    name = "aura-theme",
    lazy = false,
    priority = 1000,
    config = function(plugin, opts)
      vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
      vim.cmd.colorscheme("aura-dark")

      -- Snacks picker highlights (aura-theme doesn't define these)
      local hl = vim.api.nvim_set_hl
      hl(0, "SnacksPickerInput", { fg = "#edecee", bg = "#1c1b22" })
      hl(0, "SnacksPickerInputBorder", { fg = "#a277ff", bg = "#1c1b22" })
      hl(0, "SnacksPickerInputTitle", { fg = "#a277ff", bold = true })
      hl(0, "SnacksPickerList", { bg = "#15141b" })
      hl(0, "SnacksPickerListCursorLine", { bg = "#3d375e" })
      hl(0, "SnacksPickerMatch", { fg = "#61ffca", bold = true })
      hl(0, "SnacksPickerPreview", { bg = "#15141b" })
      hl(0, "SnacksPickerPreviewBorder", { fg = "#a277ff", bg = "#15141b" })
      hl(0, "SnacksPickerPreviewTitle", { fg = "#a277ff", bold = true })
      hl(0, "SnacksPickerBorder", { fg = "#a277ff", bg = "#15141b" })
      hl(0, "SnacksPickerTitle", { fg = "#a277ff", bold = true })
      hl(0, "SnacksPickerFile", { fg = "#edecee" })
      hl(0, "SnacksPickerDir", { fg = "#6d6d6d" })
      hl(0, "SnacksPickerRow", { fg = "#edecee" })
      hl(0, "SnacksPickerComment", { fg = "#6d6d6d" })
    end,
  },
  -- {
  --   "nyoom-engineering/oxocarbon.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.opt.background = "dark"
  --     vim.cmd [[ colorscheme oxocarbon ]]
  --   end,
  -- },
}
