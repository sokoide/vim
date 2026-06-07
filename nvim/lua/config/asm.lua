-- アセンブラソースのコメント文字自動判定
-- 1. アーキテクチャごとのコメント文字列を定義
local asm_comments = {
	m68k = "| %s",
	x86 = "# %s",
	aarch32 = "@ %s",
	aarch64 = "// %s",
}

-- 2. 自動判定ロジック
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
