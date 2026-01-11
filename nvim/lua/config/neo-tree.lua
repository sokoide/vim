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
			folder_empty = "󰉖",
			folder_empty_open = "󰉖",
			default = "",
			highlight = "NeoTreeFileIcon",
		},
		-- indent = {
		-- 	with_expanders = true,
		-- 	expander_collapsed = "󰅂",
		-- 	expander_expanded = "󰅀",
		-- 	expander_highlight = "NeoTreeExpander",
		-- },
	},
	filesystem = {
		async_directory_scan = "always", -- 常に非同期でスキャン
		-- ここが重要：ディレクトリの状態をどう扱うか
		-- 'deep' に設定すると、サブディレクトリまで含めて空かどうかを判定しようとします
		-- ただし、パフォーマンスに影響が出る可能性があるため注意
		scan_mode = "shallow",
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
