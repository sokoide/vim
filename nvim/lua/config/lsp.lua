-- 共通 capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local util = require("lspconfig.util")

local function on_attach(client, bufnr)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

------------------------------------------------------
-- Assembly (asm-lsp)
-----------------------------------------------------
vim.lsp.config("asm_lsp", {
	capabilities = capabilities,
	filetypes = { "asm", "s", "S", "nasm", "gnuasm" },
	handlers = {
		-- 大量のエラー(expected newline)を非表示にする
		["textDocument/publishDiagnostics"] = function() end,
	},
	on_attach = function(client, bufnr)
		-- 保存時のバッファ書き換えにVimが過剰反応するのを防ぐ
		vim.opt_local.cinkeys:remove("0#")
		vim.opt_local.indentkeys:remove("0#")

		-- アセンブリファイル保存時の自動処理
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				-- 1. 現在のバッファの全行を取得
				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
				local max_width = 0
				local parsed = {}

				-- 2. 1巡目: 特殊空白を掃除しつつ、コード部分の「画面上の本当の幅」を計算
				for i, line in ipairs(lines) do
					-- Webコピペ等で混入する特殊な空白(ノーブレークスペース)を通常のスペースに変換
					local clean_line = line:gsub("\xc2\xa0", " ")

					-- ★ 改良：行頭のインデント、コメント記号、中身を分解して取得
					local indent, symbol, content = clean_line:match("^(%s*)([#|])%s*(.*)$")

					if indent then
						-- 独立コメント行の場合：後ろの余分なスペースを削り、綺麗に整形する
						content = content:gsub("%s+$", "") -- 末尾の空白をトリミング
						local new_line = indent .. symbol
						if content ~= "" then
							new_line = new_line .. " " .. content -- 記号の後ろはスペース1個だけに固定
						end
						-- 整形後のラインを上書き対象（rewrite）として登録
						table.insert(parsed, { idx = i, rewrite = new_line })
					else
						-- 「|」を境にコードとコメントに分離（通常のコード＋右側コメントの行）
						local code, comment = clean_line:match("^([^|]-)%s*|%s*(.*)$")
						if code then
							code = code:gsub("%s+$", "") -- コード末尾の余分な空白だけをトリミング

							-- タブ文字 (\t) の幅も考慮して、画面上の正確な表示幅を計算
							local width = vim.fn.strdisplaywidth(code)
							if width > max_width then
								max_width = width
							end
							table.insert(parsed, { idx = i, code = code, comment = comment })
						else
							-- 「|」がない行（loop: や .text など）はそのまま無傷でキープ
							table.insert(parsed, { idx = i, orig = line })
						end
					end
				end

				-- 3. 揃える基準列を決定（最長コードの幅 + 2スペース、最低でも40列目）
				local target_col = math.max(40, max_width + 2)

				-- 4. 2巡目: 計算した位置に合わせてスペースを綺麗に補完して書き換える
				for _, item in ipairs(parsed) do
					if item.code then
						-- 通常のコード＋右側コメント行の整列
						local current_width = vim.fn.strdisplaywidth(item.code)
						local padding = string.rep(" ", target_col - current_width)
						local new_line = item.code .. padding .. "| " .. item.comment
						vim.api.nvim_buf_set_lines(bufnr, item.idx - 1, item.idx, false, { new_line })
					elseif item.rewrite then
						-- ★ 追加：独立コメント行の余分なスペースを削った状態に書き換える
						vim.api.nvim_buf_set_lines(bufnr, item.idx - 1, item.idx, false, { item.rewrite })
					end
				end
			end,
		})
	end,
})
vim.lsp.enable("asm_lsp")

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
