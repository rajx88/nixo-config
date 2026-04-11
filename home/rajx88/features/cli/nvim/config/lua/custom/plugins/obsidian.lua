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
      folder = "20-areas/journal",
      date_format = "%Y-%m-%d",
    },
    picker = {
      name = "mini.pick",
    },
    ui = {
      enable = false,
    },
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
    new_notes_location = "notes_subdir",
    notes_subdir = "50-inbox",
    attachments = {
      img_folder = "_attachments",
    },
    templates = {
      folder = "_templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
  },
  keys = {
    { "<leader>ot", function() vim.cmd("e " .. vault .. "/scratchpad.md") end, desc = "Open scratchpad" },
    { "<leader>od", "<cmd>ObsidianToday<cr>",              desc = "Open today's daily note" },
    { "<leader>on", "<cmd>ObsidianNew<cr>",                desc = "New note" },
    { "<leader>oN", "<cmd>ObsidianNewFromTemplate<cr>",    desc = "New note from template" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>",             desc = "Search notes" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>",          desc = "Note backlinks" },
    { "<leader>oo", "<cmd>ObsidianFollowLink<cr>",         desc = "Follow link" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>",              desc = "List links in note" },
    { "<leader>oi", "<cmd>ObsidianTemplate<cr>",           desc = "Insert template" },
  },
}
