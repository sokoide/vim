-- カスタム aerial バックエンド: アセンブリのラベルを抽出してシンボルアウトラインに供給する。
--
-- 背景: asm-lsp 0.10.1 は実ファイルで documentSymbol/hover が安定しない
-- （column-0 ラベルしか返さない、.segment 切り替えのある ca65 ファイルでラベルが漏れる）。
-- そこで LSP に依存せず、行頭（インデント許容）の `label:` を正規表現で抽出して
-- aerial に渡す。CPU 非依存・設定不要で全アーキテクチャの全ラベルを担保する。
--
-- aerial は backends リストに "asm" を含めると有効化。require("aerial.backends.asm")
-- としてこのファイルが解決される。
--
-- 注意: aerial 標準の add_change_watcher は config[backend_name].update_delay を参照し、
-- カスタムバックエンドには config エントリがないため nil エラーになる。
-- そのため attach では自前 autocmd で更新する。
local backends = require("aerial.backends")
local util = require("aerial.util")

local M = {}

local SUPPORTED_FT = { asm = true, s = true, S = true, nasm = true, gnuasm = true, gas = true }

M.is_supported = function(bufnr)
	for _, ft in ipairs(util.get_filetypes(bufnr)) do
		if SUPPORTED_FT[ft] then
			return true
		end
	end
	return false, "Filetype is not assembly"
end

-- 行頭（インデント許容）の `label:` を抽出する。
--   msg_a:   .asciiz "A=$"      -> "msg_a"
--   _main:                       -> "_main"
--   .L1:                         -> ".L1"   (GAS ローカルラベル)
--   .loop:                       -> ".loop" (NASM ローカルラベル)
--   .segment "RODATA"            -> (コロンがないので除外)
--   lda #<message                -> (コロンがないので除外)
M.fetch_symbols_sync = function(bufnr)
	bufnr = bufnr or 0
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
	local total = #lines
	local items = {}
	for lnum, line in ipairs(lines) do
		local label = line:match("^%s*([%w_.$][%w_.$]*)%s*:")
		if label then
			table.insert(items, {
				kind = "Function",
				name = label,
				level = 0,
				lnum = lnum,
				col = 0,
			})
		end
	end
	-- 各シンボルの終端（end_lnum/end_col）を「次のシンボルの前」またはファイル末尾に設定。
	-- これらを省略すると aerial の get_position_in_win (window.lua compare) が
	-- nil と数値を比較して "attempt to compare number with nil" で落ちる。
	for i, item in ipairs(items) do
		item.end_lnum = items[i + 1] and items[i + 1].lnum or total
		item.end_col = 0
	end
	backends.set_symbols(bufnr, items, { backend_name = "asm", lang = "asm" })
end

M.fetch_symbols = M.fetch_symbols_sync

-- 変更検知は自前 autocmd（aerial の change_watcher は config["asm"] に依存して nil エラーになるため）。
local UPDATE_EVENTS = { "BufEnter", "TextChanged", "InsertLeave", "BufWritePost" }
local UPDATE_DELAY_MS = 300

M.attach = function(bufnr)
	if not bufnr or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end
	local group = vim.api.nvim_create_augroup("AerialAsm", { clear = false })
	vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
	vim.api.nvim_create_autocmd(UPDATE_EVENTS, {
		desc = "Aerial asm: refresh labels",
		buffer = bufnr,
		group = group,
		callback = function()
			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(bufnr) and M.is_supported(bufnr) then
					M.fetch_symbols_sync(bufnr)
				end
			end, UPDATE_DELAY_MS)
		end,
	})
end

M.detach = function(bufnr)
	if not bufnr or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end
	local group = vim.api.nvim_create_augroup("AerialAsm", { clear = false })
	vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
end

return M
