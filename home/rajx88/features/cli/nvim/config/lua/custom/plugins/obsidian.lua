local vault = vim.env.OBSIDIAN_VAULT_PATH

if not vault then
  return {}
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      { name = vim.fn.fnamemodify(vault, ":t"), path = vault },
    },
    daily_notes = {
      folder = "0300-daily",
      date_format = "%Y-%m-%d",
    },
    picker = {
      name = "mini.pick",
    },
    -- Disable obsidian.nvim UI for checkboxes — checkmate handles those
    ui = {
      enable = false,
    },
    -- Follow the vault's kebab-case naming convention
    note_id_func = function(title)
      local id = ""
      if title ~= nil then
        id = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          id = id .. string.char(math.random(65, 90))
        end
      end
      return id
    end,
    -- New notes go to the inbox, matching app.json newFileFolderPath
    new_notes_location = "notes_subdir",
    notes_subdir = "0100-unsorted",
    attachments = {
      img_folder = "8000-resources/files",
    },
  },
  keys = {
    { "<leader>ot", function() vim.cmd("e " .. vault .. "/0300-todos/todo.md") end, desc = "Open todo file" },
    { "<leader>od", "<cmd>ObsidianToday<cr>",      desc = "Open today's daily note" },
    { "<leader>on", "<cmd>ObsidianNew<cr>",         desc = "New note" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>",      desc = "Search notes" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>",   desc = "Note backlinks" },
    { "<leader>oo", "<cmd>ObsidianFollowLink<cr>",  desc = "Follow link" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>",       desc = "List links in note" },
  },
}
