-- 共通 capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

local function on_attach(client, bufnr)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

-----------------------------------------------------
-- Python (pyright)
-----------------------------------------------------
vim.lsp.config("pyright", {
	capabilities = capabilities,
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
				autoSearchPaths = true,
				diagnosticMode = "workspace",
			},
		},
	},
})
vim.lsp.enable("pyright")

-----------------------------------------------------
-- Python (ruff)
-----------------------------------------------------
vim.lsp.config("ruff", {
	capabilities = capabilities,
	on_attach = on_attach,
})
vim.lsp.enable("ruff")

-----------------------------------------------------
-- JavaScript/TypeScript (eslint)
-----------------------------------------------------
vim.lsp.config("eslint", {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
	end,
})
vim.lsp.enable("eslint")

------------------------------------------------------
-- Assembly (asm-lsp)
-----------------------------------------------------
-- asm-lsp は x86/NASM/GAS 向け（6502/ca65/z80 には不適）。
-- シンボル抽出は aerial のカスタムバックエンド (aerial.backends.asm) が担当するため、
-- ここでは hover / 補完 / 定義ジャンプ用のみ。publishDiagnostics は誤報告だらけなので破棄。
-- | コメント整列・cinkeys 調整は config/asm.lua へ分離済み。
vim.lsp.config("asm_lsp", {
	capabilities = capabilities,
	filetypes = { "asm", "s", "S", "nasm", "gnuasm", "gas" },
	handlers = {
		-- 大量のエラー(expected newline)を非表示にする
		["textDocument/publishDiagnostics"] = function() end,
	},
})
vim.lsp.enable("asm_lsp")

-----------------------------------------------------
-- Go (gopls)
-----------------------------------------------------
vim.lsp.config("gopls", {
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
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

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("GoplsCodelens", { clear = true }),
	callback = function()
		vim.lsp.codelens.refresh()
	end,
})

-----------------------------------------------------
-- golangci-lint
-----------------------------------------------------
-- local root = vim.fs.dirname(vim.fs.find({ "go.mod", ".git" }, { upward = true })[1])

-- "--config=" .. root .. "/.golangci.yaml",
vim.lsp.config("golangci_lint_ls", {
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = function(fname)
		return vim.fs.root(fname, { "go.work", "go.mod", ".git" })
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
	-- AUR 版システムバイナリを使用（デフォルトの csharp-ls ではなく csharp-language-server）
	cmd = { "csharp-language-server" },
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
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "LSP definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { silent = true, desc = "LSP declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { silent = true, desc = "LSP implementation" })
vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { silent = true, desc = "LSP type definition" })
vim.keymap.set("n", "gR", vim.lsp.buf.references, { silent = true, desc = "LSP references (native)" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true, desc = "LSP hover" })

-- LSP Saga
vim.keymap.set("n", "gr", "<Cmd>Lspsaga finder<CR>", { silent = true, desc = "LSP references (Saga)" })
vim.keymap.set("n", "gp", "<Cmd>Lspsaga peek_definition<CR>", { silent = true, desc = "LSP peek definition" })
vim.keymap.set("n", "<leader>rn", "<Cmd>Lspsaga rename<CR>", { silent = true, desc = "LSP rename" })
vim.keymap.set("n", "<leader>ca", "<Cmd>Lspsaga code_action<CR>", { silent = true, desc = "LSP code action" })

-- Diagnostics
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Quickfix diagnostics
vim.keymap.set("n", "<leader>w", function()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Show warnings in quickfix" })
vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Show errors in quickfix" })
vim.keymap.set("n", "<leader>h", function()
	vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = "Show line diagnostics" })
