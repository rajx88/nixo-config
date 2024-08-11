return {
  "echasnovski/mini.nvim",
  version = false, -- this the default and recommended
  -- version = "*", -- this is the stable branch
  config = function()
    -- select magic: https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
    require("mini.ai").setup()
    -- surround text, https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-surround.md
    require("mini.surround").setup()
    -- commenting magic
    require("mini.comment").setup()
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-operators.md
    require("mini.operators").setup()
    -- shows what lines has changed
    require("mini.diff").setup()
    -- indicates the indenting scope
    require("mini.indentscope").setup()
  end,
}
