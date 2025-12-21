-- keymap
vim.keymap.set("n", "<C-p>", "<Cmd>bprevious<CR>", { silent = true })
vim.keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", "<Cmd>copen<CR><Cmd>cfirst<CR>")
-- vim.keymap.set("n", "<leader>m", "<Cmd>make<CR><Cmd>copen<CR><Cmd>cfirst<CR>", { silent = true })
-- vim.keymap.set("n", "<leader>m", "<Cmd>make<CR><Cmd>bwipeout<CR>", { silent = true })
vim.keymap.set("n", "<leader>m", "<Cmd>make!<CR><Cmd>copen<CR><Cmd>cfirst<CR>", { silent = true })

-- goto definition
vim.keymap.set("n", "<C-e>d", function()
	vim.lsp.buf.definition()
end, { desc = "Go to definition" })

vim.keymap.set("n", "<C-e>t", function()
	vim.lsp.buf.type_definition()
end, { desc = "Type definition" })

vim.keymap.set("n", "<C-e>i", function()
	vim.lsp.buf.implementation()
end, { desc = "Implementation" })

vim.keymap.set("n", "<C-e>r", function()
	vim.lsp.buf.references()
end, { desc = "Find references" })

vim.keymap.set("n", "<C-e>h", function()
	vim.lsp.buf.hover()
end, { desc = "Hover" })

vim.keymap.set("n", "<C-e>R", function()
	vim.lsp.buf.rename()
end, { desc = "Rename" })

-- neo-tree
vim.keymap.set("n", "<C-e>e", "<Cmd>Neotree toggle<CR>", { silent = true })

-- Telescope
local telescope = require("telescope.builtin")

-- find files
vim.keymap.set("n", "<leader>ff", function()
	telescope.find_files({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Finde files with <cword>" })
vim.keymap.set("n", "<leader>fg", function()
	telescope.live_grep({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Live grep with <cword>" })
-- buffer list
vim.keymap.set("n", "<leader>fb", function()
	telescope.buffers({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Find buffers with <cword>" })
-- LSP symbols
vim.keymap.set("n", "<leader>fs", telescope.lsp_document_symbols)
vim.keymap.set("n", "<leader>fS", function()
	telescope.lsp_workspace_symbols({ query = vim.fn.expand("<cword>") })
end, { desc = "Find workspace symbol <cword>" })

-- Code actions/diagnostics
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- Codex Terminal
vim.keymap.set("n", "<leader>ct", function()
	require("config.terminal").toggle_codex()
end, { desc = "Toggle Codex Terminal" })

-- Window
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

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
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial outline" })
-- nvim-dap
local dap = require("dap")
local dapui = require("dapui")

vim.keymap.set("n", "<F5>", function()
	dap.continue()
end)
vim.keymap.set("n", "<F9>", function()
	dap.toggle_breakpoint()
end)
vim.keymap.set("n", "<leader>B", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end)

vim.keymap.set("n", "<F10>", function()
	dap.step_over()
end)
vim.keymap.set("n", "<F11>", function()
	dap.step_into()
end)
vim.keymap.set("n", "<F12>", function()
	dap.step_out()
end)

vim.keymap.set("n", "<leader>dr", function()
	dap.repl.open()
end)
vim.keymap.set("n", "<leader>dt", function()
	dap.terminate()
end)
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

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
vim.keymap.set("n", "<leader>r", "<Cmd>OverseerRun make_run<CR>")
vim.keymap.set("n", "<leader>R", "<Cmd>OverseerToggle<CR>")
