-- buffer
vim.keymap.set("n", "<C-p>", "<Cmd>bprevious<CR>", { silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>q", "<Cmd>copen<CR><Cmd>cfirst<CR>", { silent = true, desc = "Open quickfix" })
vim.keymap.set("n", "<leader>ma", "<Cmd>make!<CR><Cmd>copen<CR><Cmd>cfirst<CR>", { silent = true, desc = "Run make" })
vim.keymap.set("n", "<leader>]", "<Cmd>qa<CR>", { silent = true, desc = "Quit all" })

-- markdown
vim.keymap.set(
	"n",
	"<leader>md",
	"<Cmd>RenderMarkdown toggle<CR><Cmd>MdTableAlignAll<CR>",
	{ silent = true, desc = "Toggle Markdown render + align tables" }
)

-- neo-tree
vim.keymap.set("n", "<C-e>e", "<Cmd>Neotree toggle<CR>", { silent = true, desc = "Toggle Neo-tree" })

-- Telescope (lazy require)
vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Find files with <cword>" })
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").live_grep({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Live grep with <cword>" })
vim.keymap.set("n", "<leader>fb", function()
	require("telescope.builtin").buffers({ default_text = vim.fn.expand("<cword>") })
end, { desc = "Find buffers with <cword>" })
vim.keymap.set("n", "<leader>fs", function()
	require("telescope.builtin").lsp_document_symbols()
end, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fS", function()
	require("telescope.builtin").lsp_workspace_symbols({ query = vim.fn.expand("<cword>") })
end, { desc = "Find workspace symbol <cword>" })
vim.keymap.set("n", "<leader>fr", function()
	require("telescope.builtin").lsp_references()
end, { silent = true, desc = "LSP references" })

-- Window
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Resize window width
vim.keymap.set("n", "<leader>+", "<C-w>5>", { desc = "Increase window width by 5" })
vim.keymap.set("n", "<leader>-", "<C-w>5<", { desc = "Decrease window width by 5" })

-- Aerial
vim.keymap.set("n", "<leader>ao", "<Cmd>AerialToggle!<CR>", { silent = true, desc = "Toggle Aerial outline" })

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
