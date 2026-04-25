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
	return path:gsub(
		"/Users/scott/Library/CloudStorage/OneDrive%-Personal/",
		"/Users/scott/"
	)
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
