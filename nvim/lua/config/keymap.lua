-- buffer
vim.keymap.set("n", "<C-p>", "<Cmd>bprevious<CR>", { silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>q", "<Cmd>copen<CR><Cmd>cfirst<CR>", { silent = true, desc = "Open quickfix" })
vim.keymap.set("n", "<leader>ma", "<Cmd>make!<CR><Cmd>copen<CR><Cmd>cfirst<CR>", { silent = true, desc = "Run make" })
vim.keymap.set("n", "<leader>]", "<Cmd>qa<CR>", { silent = true, desc = "Quit all" })

-- markdown
vim.keymap.set("n", "<leader>md", "<Cmd>RenderMarkdown toggle<CR>", { silent = true, desc = "Toggle Markdown render" })

-- neo-tree
vim.keymap.set("n", "<C-e>e", "<Cmd>Neotree toggle<CR>", { silent = true, desc = "Toggle Neo-tree" })

-- LSP Saga
vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", { noremap = true, silent = true, desc = "LSP references" })
vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { noremap = true, silent = true, desc = "LSP peek definition" })
vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { noremap = true, silent = true, desc = "LSP rename" })
vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { noremap = true, silent = true, desc = "LSP code action" })

-- Diagnostics
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Telescope
local telescope = require("telescope.builtin")

-- find files
vim.keymap.set("n", "<leader>ff", function()
	telescope.find_files({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Find files with <cword>" })
-- live grep
vim.keymap.set("n", "<leader>fg", function()
	telescope.live_grep({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Live grep with <cword>" })
-- buffer list
vim.keymap.set("n", "<leader>fb", function()
	telescope.buffers({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Find buffers with <cword>" })
-- LSP symbols
vim.keymap.set("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fS", function()
	telescope.lsp_workspace_symbols({ query = vim.fn.expand("<cword>") })
end, { desc = "Find workspace symbol <cword>" })

-- references
vim.keymap.set("n", "<leader>fr", telescope.lsp_references, { noremap = true, silent = true, desc = "LSP references" })

-- Codex Terminal
vim.keymap.set("n", "<leader>ct", function()
	require("config.terminal").toggle_codex()
end, { desc = "Toggle Codex Terminal" })

vim.keymap.set("n", "<leader>ag", function()
	require("config.terminal").toggle_gemini()
end, { desc = "Toggle Gemini CLI" })

vim.keymap.set("n", "<leader>ac", function()
	require("config.terminal").toggle_claude()
end, { desc = "Toggle Claude CLI" })

-- Window
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Resize window width
vim.keymap.set("n", "<leader>+", "<C-w>5>", { desc = "Increase window width by 5" })
vim.keymap.set("n", "<leader>-", "<C-w>5<", { desc = "Decrease window width by 5" })

-- warnings & errors
vim.keymap.set("n", "<leader>w", function()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Show warnings in quickfix" })
vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Show errors in quickfix" })
vim.keymap.set("n", "<leader>h", function()
	vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = "Show line diagnostics" })

-- Aerial
vim.keymap.set("n", "<leader>ao", "<cmd>AerialToggle!<CR>", { silent = true, desc = "Toggle Aerial outline" })
-- nvim-dap
local dap = require("dap")
local dapui = require("dapui")

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignInfo", linehl = "DapStoppedLine", numhl = "" })

vim.keymap.set("n", "<F5>", function()
	dap.continue()
end, { desc = "DAP continue" })
vim.keymap.set("n", "<A-r>", function()
	dap.continue()
end, { desc = "DAP continue" })

vim.keymap.set("n", "<F9>", function()
	dap.toggle_breakpoint()
end, { desc = "DAP toggle breakpoint" })
vim.keymap.set("n", "<A-b>", function()
	dap.toggle_breakpoint()
end, { desc = "DAP toggle breakpoint" })

vim.keymap.set("n", "<F10>", function()
	dap.step_over()
end, { desc = "DAP step over" })
vim.keymap.set("n", "<A-;>", function()
	dap.step_over()
end, { desc = "DAP step over" })

vim.keymap.set("n", "<F11>", function()
	dap.step_into()
end, { desc = "DAP step into" })
vim.keymap.set("n", "<A-'>", function()
	dap.step_into()
end, { desc = "DAP step into" })

vim.keymap.set("n", "<F12>", function()
	dap.step_out()
end, { desc = "DAP step out" })
vim.keymap.set("n", "<A-/>", function()
	dap.step_out()
end, { desc = "DAP step out" })

vim.keymap.set("n", "<leader>dr", function()
	dap.repl.open()
end, { desc = "DAP REPL open" })
vim.keymap.set("n", "<leader>dt", function()
	dap.terminate()
end, { desc = "DAP terminate" })
-- DAP UI maximize/restore toggle
local dapui_maximized = false

vim.keymap.set("n", "<leader>du", function()
	if dapui_maximized then
		-- Restore: reopen DAP UI
		dapui.close()
		dapui.open()
		dapui_maximized = false
	else
		-- Maximize: close other DAP UI windows
		local current_win = vim.api.nvim_get_current_win()
		local current_buf = vim.api.nvim_win_get_buf(current_win)
		local current_name = vim.api.nvim_buf_get_name(current_buf)

		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if win ~= current_win then
				local buf = vim.api.nvim_win_get_buf(win)
				local name = vim.api.nvim_buf_get_name(buf)
				-- Check if it's a DAP UI buffer (matches "DAP " prefix or "[dap-repl")
				if name:match("DAP ") or name:match("%[dap%-") then
					vim.api.nvim_win_close(win, true)
				end
			end
		end
		dapui_maximized = true
	end
end, { desc = "Maximize/Restore DAP UI pane" })
-- =========================================
-- Go Test Runner (QuickFix)
-- =========================================

local function get_go_project_root()
	local path = vim.api.nvim_buf_get_name(0)
	local mod = vim.fs.find("go.mod", { upward = true, path = path })[1]
	return mod and vim.fs.dirname(mod) or nil
end

local function go_test_runner(mode)
	-- Detect Go project root
	local root = get_go_project_root()
	if not root then
		vim.notify("go.mod not found", vim.log.levels.ERROR)
		return
	end

	vim.cmd("cd " .. root)

	local cmd = nil

	if mode == "function" then
		local func = vim.fn.expand("<cword>")

		-- ★★★ ここが重要：function 名がなければ実行しない
		if not func:match("^Test") then
			vim.notify("カーソルをテスト関数名 (Test*) の上に置いてください", vim.log.levels.WARN)
			return
		end

		cmd = "go test -v -run " .. func
	elseif mode == "file" then
		cmd = "go test -v " .. vim.fn.expand("%")
	elseif mode == "all" then
		cmd = "go test -v ./..."
	end

	-- 実行
	vim.cmd("cexpr system('" .. cmd .. "')")
	vim.cmd("copen")
end

-- Test current function
vim.keymap.set("n", "<leader>tf", function()
	go_test_runner("function")
end, { desc = "Run Go Test for current function" })

-- Test current file
vim.keymap.set("n", "<leader>tt", function()
	go_test_runner("file")
end, { desc = "Run Go Test for this file" })

-- Test entire package/module
vim.keymap.set("n", "<leader>ta", function()
	go_test_runner("all")
end, { desc = "Run Go Test for all packages" })

-- overseer
vim.keymap.set("n", "<leader>r", "<Cmd>OverseerRun make_run<CR>", { silent = true, desc = "Overseer run" })
vim.keymap.set("n", "<leader>R", "<Cmd>OverseerToggle<CR>", { silent = true, desc = "Overseer toggle" })
vim.keymap.set("n", "<leader>k", function()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({ running = true })
	if #tasks > 0 then
		tasks[1]:stop()
		vim.notify("Task stopped: " .. tasks[1].name)
	else
		vim.notify("No running tasks")
	end
end, { desc = "Kill running Overseer task" })

-- vim-fugitive
vim.keymap.set("n", "<leader>gd", ":Gvdiffsplit<CR>", { silent = true, desc = "Git Diff (Index)" })
vim.keymap.set("n", "<leader>gh", ":Gvdiffsplit HEAD<CR>", { silent = true, desc = "Git Diff (HEAD)" })

-- gx
vim.keymap.set({ "n", "v" }, "gx", function()
	local url = vim.fn.expand("<cfile>")
	if url:match("^https?://") then
		-- URLの場合、OSのデフォルトブラウザで開く
		if vim.fn.has("mac") == 1 then
			vim.fn.jobstart({ "open", url })
		elseif vim.fn.has("unix") == 1 then
			vim.fn.jobstart({ "xdg-open", url })
		elseif vim.fn.has("win32") == 1 then
			vim.fn.jobstart({ "cmd", "/c", "start", url })
		end
	else
		-- URLでない場合は、標準の netrw の gx を実行
		vim.cmd("normal! gx")
	end
end, { desc = "Open URL under cursor" })
