require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "cpp", "go", "rust", "python", "lua", "vim" },
	highlight = { enable = true },
})
