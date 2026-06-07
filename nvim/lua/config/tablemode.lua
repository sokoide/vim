vim.cmd("TableModeEnable")

-- カレントバッファの全テーブルを一括整列
-- テーブル先頭で1回だけ TableModeRealign を呼ぶ方式
vim.api.nvim_create_user_command("MdTableAlignAll", function()
	local winview = vim.fn.winsaveview()
	local total = vim.fn.line("$")
	local cur = 1
	while cur <= total do
		if vim.fn.getline(cur):match("^%s*|") then
			-- テーブル先頭行にカーソルを移動
			-- 1回だけ呼ぶ（TableModeRealign はテーブル全体を処理する）
			vim.fn.cursor(cur, 1)
			vim.fn["tablemode#table#Realign"](".")
			-- 次のテーブルブロックへスキップ
			while cur <= total and vim.fn.getline(cur):match("^%s*|") do
				cur = cur + 1
			end
		else
			cur = cur + 1
		end
	end
	vim.fn.winrestview(winview)
end, { desc = "Realign all markdown tables in buffer" })
