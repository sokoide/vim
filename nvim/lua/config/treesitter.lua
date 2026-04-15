require("nvim-treesitter").setup({
	ensure_installed = { "c", "cpp", "go", "rust", "python", "lua", "vim", "yaml", "markdown", "markdown_inline" },
	highlight = { enable = true },
})
