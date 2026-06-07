local dap = require("dap")

-- adapter
local lldb_dap_cmd = vim.fn.exepath("lldb-dap")
if lldb_dap_cmd == "" then
	lldb_dap_cmd = vim.fn.has("mac") == 1 and "/opt/homebrew/opt/llvm/bin/lldb-dap"
		or "/data/data/com.termux/files/usr/bin/lldb-dap"
end

dap.adapters.lldb = {
	type = "executable",
	command = lldb_dap_cmd,
	name = "lldb",
	filetypes = { "c", "cpp" },
}

-- CloudStorageパスをシンボリックリンクパスに変換
local function remap_path(path)
	if not path then
		return nil
	end
	return path:gsub("/Users/scott/Library/CloudStorage/OneDrive%-Personal/", "/Users/scott/")
end

-- Session.requestをラップしてsetBreakpoints送信前にパスを書き換え
local Session = require("dap.session")
local orig_request = Session.request
Session.request = function(self, command, arguments, callback)
	if command == "setBreakpoints" and arguments and arguments.source and arguments.source.path then
		arguments.source.path = remap_path(arguments.source.path)
	end
	return orig_request(self, command, arguments, callback)
end

-- launch.jsonからprogramパスを取得
local function get_launch_program()
	local path = vim.fn.getcwd() .. "/.vscode/launch.json"
	if vim.fn.filereadable(path) == 1 then
		local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
		if ok and data and data.configurations then
			for _, cfg in ipairs(data.configurations) do
				if cfg.program then
					return cfg.program:gsub("${env:HOME}", os.getenv("HOME"))
				end
			end
		end
	end
	return vim.fn.getcwd() .. "/"
end

-- .vscode/launch.json がある場合はそちらを使い、静的設定は登録しない
if vim.fn.filereadable(vim.fn.getcwd() .. "/.vscode/launch.json") == 0 then
	dap.configurations.cpp = {
		{
			name = "Launch C++",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", get_launch_program(), "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
			initCommands = {
				"breakpoint set --name main",
			},
		},
	}

	-- C も C++ と同じ設定を共有
	dap.configurations.c = dap.configurations.cpp
end

-----------------------------------------------------
-- Signs
-----------------------------------------------------
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignInfo", linehl = "DapStoppedLine", numhl = "" })

-----------------------------------------------------
-- Keymaps
-----------------------------------------------------
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
local dapui = require("dapui")
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
