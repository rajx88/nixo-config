return {
    'rose-pine/neovim',
    name = 'rose-pine',
	opts = {
		disable_background = true
	},
	config = function()
		-- settings colorscheme
		vim.cmd.colorscheme("rose-pine")
		-- vim.g.rose_pine_disable_background = true
	end
}
