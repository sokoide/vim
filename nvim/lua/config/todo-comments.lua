require("todo-comments").setup({
	signs = true,
	sign_priority = 8,
	keywords = {
		FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
		TODO = { icon = " ", color = "info" },
		HACK = { icon = " ", color = "warning" },
		WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
		PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
		NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
		TEST = { icon = "⏣ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
	},
	highlight = {
		multiline = true,
		multiline_pattern = "^.",
		before = "",
		keyword = "wide",
		after = "fg",
	},
})

-- Telescope 拡張を読み込む
require("telescope").load_extension("todo-comments")

-- todo navigation
vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { silent = true, desc = "Next todo comment" })
vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { silent = true, desc = "Previous todo comment" })

-- Telescope で todo 一覧
vim.keymap.set("n", "<leader>ft", "<Cmd>TodoTelescope<CR>", { silent = true, desc = "Find todo comments" })
