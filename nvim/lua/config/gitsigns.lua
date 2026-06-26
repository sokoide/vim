require("gitsigns").setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol",
		delay = 500,
	},
	signcolumn = true,
	numhl = true,
})

-- hunk navigation
vim.keymap.set("n", "]g", "<Cmd>Gitsigns next_hunk<CR>", { silent = true, desc = "Next git hunk" })
vim.keymap.set("n", "[g", "<Cmd>Gitsigns prev_hunk<CR>", { silent = true, desc = "Previous git hunk" })

-- hunk actions
vim.keymap.set("n", "<leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", { silent = true, desc = "Stage git hunk" })
vim.keymap.set("v", "<leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", { silent = true, desc = "Stage git hunk" })
vim.keymap.set("n", "<leader>gr", "<Cmd>Gitsigns reset_hunk<CR>", { silent = true, desc = "Reset git hunk" })
vim.keymap.set("n", "<leader>gp", "<Cmd>Gitsigns preview_hunk<CR>", { silent = true, desc = "Preview git hunk" })

-- blame
vim.keymap.set("n", "<leader>gb", "<Cmd>Gitsigns blame_line<CR>", { silent = true, desc = "Git blame line" })
