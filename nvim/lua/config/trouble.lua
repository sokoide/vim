require("trouble").setup({
	icons = true,
	fold_open = "",
	fold_closed = "",
	indent_lines = false,
	signs = {
		error = "",
		warning = "",
		hint = "",
		information = "",
		other = "",
	},
	use_diagnostic_signs = true,
	action_keys = {
		close = "q",
		cancel = "<esc>",
	},
})

-- diagnostics
vim.keymap.set("n", "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", { silent = true, desc = "Toggle all diagnostics" })
vim.keymap.set(
	"n",
	"<leader>xw",
	"<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
	{ silent = true, desc = "Toggle buffer diagnostics" }
)

-- document symbols / quickfix
vim.keymap.set(
	"n",
	"<leader>xd",
	"<Cmd>Trouble document_diagnostics toggle<CR>",
	{ silent = true, desc = "Toggle document diagnostics" }
)
vim.keymap.set("n", "<leader>xq", "<Cmd>Trouble quickfix toggle<CR>", { silent = true, desc = "Toggle quickfix" })
