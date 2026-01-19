require("nvim-treesitter").setup({
	ensure_installed = { "c", "cpp", "go", "rust", "python", "lua", "vim" },
	highlight = { enable = true },
})
