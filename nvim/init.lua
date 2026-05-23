-- Termux: set temp directory (no /tmp on Android or it's not writable)
if vim.env.TERMUX_VERSION then
	local tmp = (vim.env.PREFIX or "/data/data/com.termux/files/usr") .. "/tmp"
	if vim.fn.isdirectory(tmp) == 0 then
		vim.fn.mkdir(tmp, "p")
	end
	vim.env.TMPDIR = tmp
	vim.env.XDG_RUNTIME_DIR = tmp
end

-- Source ~/.glm for API keys (ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, etc.)
do
	local f = io.open(vim.fn.expand("~/.glm"), "r")
	if f then
		for line in f:lines() do
			local k, v = line:match("^export%s+(%S+)=(.+)")
			if k and v then
				v = v:gsub("^[\"']", ""):gsub("[\"']$", "")
				vim.env[k] = v
			end
		end
		f:close()
	end
end

--  lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true

-- Auto-reload files changed externally
local function watch_file(bufnr)
	local file_path = vim.api.nvim_buf_get_name(bufnr)
	if file_path == "" or file_path:match("://") then
		return
	end

	local w = vim.uv.new_fs_event()
	if not w then
		return
	end

	w:start(
		file_path,
		{},
		vim.schedule_wrap(function(err)
			if err then
				w:stop()
				return
			end
			vim.cmd("checktime")
		end)
	)

	-- バッファを閉じたら監視も止める（ここが重要！）
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = bufnr,
		once = true,
		callback = function()
			if not w:is_closing() then
				w:stop()
			end
		end,
	})
end

-- バッファを開いた時に監視を開始する
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("VimImmediateReload", { clear = true }),
	callback = function(args)
		watch_file(args.buf)
	end,
})

-- autoread自体は有効にしておく
vim.o.autoread = true

-- FocusGained（フォーカス移動）と CursorHold（アイドル時）でチェックする
vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold", "BufEnter" }, {
	callback = function()
		-- コマンド入力中でなければチェックする
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- keymap
require("config.keymap")

-- Disable completion/analysis for CodeCompanion chat buffers
vim.api.nvim_create_autocmd("FileType", {
	pattern = "codecompanion",
	callback = function()
		vim.b.completion = false
		-- Disable treesitter for this buffer
		vim.treesitter.stop()
	end,
})

-- quick close
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help", "man", "lspinfo", "Trouble", "toggleterm" },
	callback = function()
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
	end,
})

-- comment
-- 1. アーキテクチャごとのコメント文字列を定義
local asm_comments = {
	m68k = "| %s",
	x86 = "# %s",
	aarch32 = "@ %s",
	aarch64 = "// %s",
}

-- 2. 自動判定ロジックの関数
local function detect_asm_arch()
	local path = vim.fn.expand("%:p"):lower()

	-- 【判定フェーズ1】ファイルパス（フォルダ名など）から推測
	if path:match("68k") or path:match("68000") or path:match("m68k") then
		return "m68k"
	elseif path:match("x86") or path:match("amd64") or path:match("i386") then
		return "x86"
	elseif path:match("aarch64") or path:match("arm64") or path:match("v8") then
		return "aarch64"
	elseif path:match("arm") or path:match("aarch") or path:match("v7") then
		return "aarch32"
	end

	-- 【判定フェーズ2】ファイル先頭30行の中身から推測
	local lines = vim.api.nvim_buf_get_lines(0, 0, 30, false)
	for _, line in ipairs(lines) do
		line = " " .. line:lower() -- 前方にスペースを足してマッチしやすくする

		-- x86: %rax, %eax, .intel_syntax など
		if line:match("%%[er]?[abcd]x") or line:match("%%[er]?si") or line:match("%.intel_syntax") then
			return "x86"
		-- aarch64: x0~x30, w0~w30 レジスタ
		elseif line:match("%s[xw][0-2]?[0-9]") or line:match("%s[xw]3[01]") then
			return "aarch64"
		-- 68000: d0~d7, a0~a7 レジスタ
		elseif line:match("%s[da][0-7]") then
			return "m68k"
		-- aarch32: r0~r15 レジスタ（他と被りやすいので最後に判定）
		elseif line:match("%sr[0-1]?[0-5]") then
			return "aarch32"
		end
	end

	return nil -- 判定できなかった場合
end

-- 3. autocmd でファイルを開いたときに実行
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.s",
	callback = function()
		local arch = detect_asm_arch()
		if arch and asm_comments[arch] then
			vim.bo.commentstring = asm_comments[arch]
		else
			-- どれにも引っかからなかった場合のデフォルト（例: x86用の # ）
			vim.bo.commentstring = "# %s"
		end
	end,
})

-- 4. 【救済措置】手動で切り替えるためのユーザーコマンド
-- 例： :AsmArch m68k  や  :AsmArch aarch64  で切り替え可能（タブ補完付き）
vim.api.nvim_create_user_command("AsmArch", function(opts)
	local arch = opts.args
	if asm_comments[arch] then
		vim.bo.commentstring = asm_comments[arch]
		print("Comment syntax set for: " .. arch .. " (" .. asm_comments[arch]:sub(1, 2) .. ")")
	else
		print("Unknown architecture. Choose from: m68k, x86, aarch32, aarch64")
	end
end, {
	nargs = 1,
	complete = function()
		return { "m68k", "x86", "aarch32", "aarch64" }
	end,
})

--- initial launcy by nvim -d
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.o.diff then
			-- 全てのウィンドウ（左右の比較画面）でwrapを有効にする
			vim.cmd("windo set wrap")
		end
	end,
})
local diffgroup = vim.api.nvim_create_augroup("DiffWrap", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "OptionSet" }, {
	group = diffgroup,
	pattern = "*",
	callback = function()
		if vim.wo.diff then
			vim.wo.wrap = true
		end
	end,
})
-- manual :diffthis
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "diff",
	callback = function()
		if vim.v.option_new == "true" or vim.v.option_new == 1 then
			vim.wo.wrap = true
		end
	end,
})

-- color scheme
-- vim.cmd("colorscheme tokyonight")
