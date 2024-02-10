return {

        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                fish = { "fish_indent" },
                sh = { "shfmt" },
                nix = {"alejandra"},
                go = { "goimports", "gofmt" },
                javascript = {{ "prettierd", "prettier" }} ,
                typescript = {{ "prettierd", "prettier" }} ,
                javascriptreact = {{ "prettierd", "prettier" }} ,
                typescriptreact = {{ "prettierd", "prettier" }} ,
                css = {{ "prettierd", "prettier" }} ,
                html = {{ "prettierd", "prettier" }} ,
                json = {{ "prettierd", "prettier" }} ,
                yaml = {{ "prettierd", "prettier" }} ,
                markdown = {{ "prettierd", "prettier" }} ,
                graphql = {{ "prettierd", "prettier" }} ,
              },
        }
 
}
