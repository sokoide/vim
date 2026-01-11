-- 共通 capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local util = require("lspconfig.util")

local function on_attach(client, bufnr)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

-----------------------------------------------------
-- Go (gopls)
-----------------------------------------------------
vim.lsp.config("gopls", {
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		-- client.server_capabilities.codeLensProvider = nil
	end,

	capabilities = capabilities,
	settings = {
		gopls = {
			analyses = { unusedparams = true },
			staticcheck = true,
		},
	},
})
vim.lsp.enable("gopls")

-----------------------------------------------------
-- golangci-lint
-----------------------------------------------------
-- local root = vim.fs.dirname(vim.fs.find({ "go.mod", ".git" }, { upward = true })[1])

-- "--config=" .. root .. "/.golangci.yaml",
vim.lsp.config("golangci_lint_ls", {
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = function(fname)
		return util.root_pattern("go.work", "go.mod", ".git")(fname)
	end,
	init_options = {
		command = {
			"golangci-lint",
			"run",
			"--config=" .. os.getenv("HOME") .. "/.golangci.yaml",
			"--disable",
			"lll",
			"--issues-exit-code=1",
		},
	},
})
vim.lsp.enable("golangci_lint_ls")

-----------------------------------------------------
-- C/C++ (clangd)
-----------------------------------------------------
vim.lsp.config("clangd", {
	capabilities = capabilities,
	cmd = { "clangd", "--background-index", "--header-insertion=never" },
})
vim.lsp.enable("clangd")

-----------------------------------------------------
-- Rust (rust-analyzer)
-----------------------------------------------------
vim.lsp.config("rust_analyzer", {
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			cargo = { allFeatures = true },
			checkOnSave = { command = "clippy" },
		},
	},
})
vim.lsp.enable("rust_analyzer")

-----------------------------------------------------
-- TypeScript / JavaScript
-- tsserver → 完全廃止。新名: ts_ls
-----------------------------------------------------
vim.lsp.config("ts_ls", {
	capabilities = capabilities,
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
	end,
})
vim.lsp.enable("ts_ls")

-----------------------------------------------------
-- C#
-----------------------------------------------------
vim.lsp.config("csharp_ls", {
	capabilities = capabilities,
})
vim.lsp.enable("csharp_ls")

-----------------------------------------------------
-- Java (jdtls)
-----------------------------------------------------
vim.lsp.config("jdtls", {
	capabilities = capabilities,
})
vim.lsp.enable("jdtls")

-----------------------------------------------------
-- Keymaps (全 LSP 共通)
-----------------------------------------------------
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
