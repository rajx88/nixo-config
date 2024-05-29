return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-smart-history.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    -- this is installed in the default.nix file in the main neovim directory.
    -- because sqllite dependency is needed for the plugin
    -- it retrieves the 'so' file from the nix store
    --"kkharji/sqlite.lua",
  },
  config = function()
    local data = assert(vim.fn.stdpath "data") --[[@as string]]
    require("telescope").setup {
      extensions = {
        wrap_results = true,

        fzf = {},
        history = {
          path = vim.fs.joinpath(data, "telescope_history.sqlite3"),
          limit = 100,
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown {},
        },
      },
    }

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "smart_history")
    pcall(require("telescope").load_extension, "ui-select")

    local builtin = require "telescope.builtin"

    vim.keymap.set("n", "<leader>fd", builtin.find_files)
    vim.keymap.set("n", "<leader>ft", builtin.git_files)
    vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)

    vim.keymap.set("n", "<leader>gw", builtin.grep_string)
  end,
}
