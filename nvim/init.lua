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

-- OSC 52 を使ってクリップボードを設定
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}

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
		vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = true, silent = true })
	end,
})

-- asm comment detection
require("config.asm")

-- diff mode wrap
require("config.diff")

-- :README — ガイドをフローティングウィンドウで表示
vim.api.nvim_create_user_command("README", function()
	local path = vim.fn.stdpath("config") .. "/README.md"
	if vim.fn.filereadable(path) == 0 then
		vim.notify("README.md not found: " .. path, vim.log.levels.ERROR)
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "readonly", true)
	vim.bo[buf].filetype = "markdown"

	local lines = vim.fn.readfile(path)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = math.min(math.floor(vim.o.columns * 0.8), 100)
	local height = math.min(math.floor(vim.o.lines * 0.85), 60)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		border = "rounded",
		style = "minimal",
	})
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "signcolumn", "no")

	-- q で閉じる
	vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = true, silent = true })
end, { desc = "Open config README" })
