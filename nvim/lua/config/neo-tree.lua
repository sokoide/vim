local function smart_open(state)
	local node = state.tree:get_node()
	if node.type == "directory" then
		require("neo-tree.sources.filesystem").toggle_directory(state, node)
	else
		require("neo-tree.sources.common.commands").open(state)
	end
end

require("neo-tree").setup({
	default_component_configs = {
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "󰉖",
			folder_empty_open = "󰉖",
			default = "",
			highlight = "NeoTreeFileIcon",
		},
	},
	filesystem = {
		async_directory_scan = "always",
		scan_mode = "shallow",
	},
	window = {
		width = 24,
		mappings = {
			["o"] = smart_open,
			["<space>"] = "none",
			["x"] = "close_node",
			["s"] = "open_split",
			["v"] = "open_vsplit",
		},
	},
})

vim.keymap.set("n", "<C-e>e", ":Neotree toggle<CR>")
