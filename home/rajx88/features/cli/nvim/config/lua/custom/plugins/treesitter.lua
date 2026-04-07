return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install {
      "bash",
      "diff",
      "go",
      "html",
      "java",
      "javascript",
      "jsdoc",
      "jsonnet",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "templ",
      "typescript",
      "vim",
      "vimdoc",
    }

    -- Enable treesitter-based indentation (not automatic in Neovim 0.12)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
