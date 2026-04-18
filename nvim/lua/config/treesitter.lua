require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "cpp", "go", "rust", "python", "lua", "vim", "yaml", "markdown", "markdown_inline" },
	sync_install = false,
	highlight = { enable = true },
})
