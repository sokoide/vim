-- diff モード時に常に wrap を有効にする
-- nvim -d 起動時
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.o.diff then
			vim.cmd("windo set wrap")
		end
	end,
})

-- diff モードに入ったときの wrap 強制
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

-- :diffthis 手動実行時
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "diff",
	callback = function()
		if vim.v.option_new == "true" or vim.v.option_new == 1 then
			vim.wo.wrap = true
		end
	end,
})
