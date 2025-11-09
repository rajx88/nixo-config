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
    require("mini.icons").setup()
  end,
}
