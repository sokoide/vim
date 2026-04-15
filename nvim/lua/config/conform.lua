local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		c = { "clang_format" },
		cpp = { "clang_format" },
		cs = { "csharpier" }, -- C#
		go = { "goimports", "gofmt" },
		h = { "clang_format" },
		java = { "google-java-format" }, -- Java
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		json = { "prettierd", "prettier", "jq", stop_after_first = true },
		lua = { "stylua" },
		rust = { "rustfmt" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
	},

	format_on_save = function(bufnr)
		local exclude_ft = { "sh", "bash", "zsh" }
		if vim.tbl_contains(exclude_ft, vim.bo[bufnr].filetype) then
			return
		end

		return {
			timeout_ms = 2000,
			lsp_fallback = true, -- sh以外はLSPに頼る
		}
	end,
})

conform.formatters.clang_format = {
	command = "clang-format",
	args = { "-style=file", "-assume-filename", vim.api.nvim_buf_get_name(0) },
}
