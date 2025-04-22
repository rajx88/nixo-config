return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fb",
      function()
        require("conform").format { async = true, lsp_format = "fallback" }
      end,
      mode = "",
      desc = "[F]ormat [B]uffer",
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
      nix = { "alejandra" },
      go = { "goimports", "gofumpt" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      css = { "prettierd" },
      html = { "prettierd" },
      json = { "prettierd" },
      yaml = { "prettierd" },
      markdown = { "prettierd" },
      graphql = { "prettierd" },
    },
  },
  -- -- enables auto format on save, copied from the github.
  -- vim.api.nvim_create_autocmd("BufWritePre", {
  --   callback = function(args)
  --     require("conform").format {
  --       bufnr = args.buf,
  --       lsp_fallback = true,
  --       quiet = true,
  --     }
  --   end,
  -- })
}
