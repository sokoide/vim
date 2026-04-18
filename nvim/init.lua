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
