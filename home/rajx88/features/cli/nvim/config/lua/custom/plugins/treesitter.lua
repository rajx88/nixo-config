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
      "gotmpl",
      "helm",
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

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        -- Enable treesitter-based indentation (not automatic in Neovim 0.12)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        -- Auto-enable treesitter highlighting for all installed parsers.
        -- Neovim 0.12 only auto-starts highlighting for bundled parsers;
        -- this covers non-bundled ones (helm, go, java, etc.).
        local lang = vim.treesitter.language.get_lang(args.match)
        if lang and vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false)[1] then
          vim.treesitter.start(args.buf)
        end
      end,
    })
  end,
}
