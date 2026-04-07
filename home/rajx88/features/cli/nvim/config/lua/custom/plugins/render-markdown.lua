return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  ft = { "markdown" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- Enable by default (was off until toggled)
    enabled = true,
    -- Checkbox rendering: use icons to match checkmate states
    checkbox = {
      enabled = true,
      unchecked = { icon = "󰄱 " },
      checked   = { icon = "󰱒 " },
      custom = {
        -- checkmate in_progress state
        in_progress = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        -- checkmate cancelled state
        cancelled   = { raw = "[~]", rendered = "󰜺 ", highlight = "RenderMarkdownError" },
      },
    },
    -- Heading decorations
    heading = {
      enabled = true,
      sign    = false,  -- cleaner without sign column icons
      icons   = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
    },
  },
  keys = {
    { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle render markdown" },
  },
}
