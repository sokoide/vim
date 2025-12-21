local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		go = { "goimports", "gofmt" },
		rust = { "rustfmt" },
		cpp = { "clang_format" },
		c = { "clang_format" },
		h = { "clang_format" },

		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },

		cs = { "csharpier" }, -- C#
		java = { "google-java-format" }, -- Java
		lua = { "stylua" },
	},

	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 2000,
	},
})

conform.formatters.clang_format = {
	command = "clang-format",
	args = { "-style=file", "-assume-filename=.clang-format" },
}
