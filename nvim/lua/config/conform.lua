local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		asm = { "asmfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		cs = { "prettier" },
		go = { "goimports", "gofmt" },
		h = { "clang-format" },
		java = { "google-java-format" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		json = { "prettierd", "prettier", "jq", stop_after_first = true },
		jsonc = { "prettierd", "prettier", stop_after_first = true },
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
			lsp_fallback = true,
		}
	end,
})

conform.formatters.clang_format = {
	command = "clang-format",
	args = function(ctx)
		local filename = ctx.bufname or "untitled.cpp"
		if filename == "" then
			filename = "untitled.cpp"
		end
		return { "--assume-filename=" .. filename, "--style=file" }
	end,
}
