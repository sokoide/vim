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

local prettier_config = vim.fn.expand("~") .. "/.prettierrc.json"

conform.formatters.prettier = {
	command = "prettier",
	prepend_args = function(ctx)
		return { "--config", prettier_config }
	end,
}

conform.formatters.prettierd = {
	command = "prettierd",
	env = {
		PRETTIERD_DEFAULT_CONFIG = prettier_config,
	},
}
