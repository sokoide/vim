local function smart_open(state)
	local node = state.tree:get_node()
	if node.type == "directory" then
		require("neo-tree.sources.filesystem").toggle_directory(state, node)
	else
		require("neo-tree.sources.common.commands").open(state)
	end
end

require("neo-tree").setup({
	width = 32,
	default_component_configs = {
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "ﰊ",
			default = "",
			highlight = "NeoTreeFileIcon",
		},
	},
	window = {
		mappings = {
			["o"] = smart_open, -- ← 一行どこで押しても NERDTree と同じ
			["<space>"] = "none", -- ← 左端 space の “menu” を完全に無効化
			["x"] = "close_node",
			["s"] = "open_split",
			["v"] = "open_vsplit",
		},
	},
})

vim.keymap.set("n", "<C-e>e", ":Neotree toggle<CR>")
