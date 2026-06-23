-- アセンブラソースのコメント文字自動判定 + | コメント整列
-- （| 整形ロジックは元 lsp.lua の asm_lsp.on_attach から分離）

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

-- 3. | 区切りコメントの整列（m68k 等で有効。| を持たない行は無害そのまま）
--    元々 asm_lsp.on_attach にあった保存時整形ロジック。
local function align_pipe_comments(bufnr)
	-- 1. 現在のバッファの全行を取得
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local max_width = 0
	local parsed = {}

	-- 2. 1巡目: 特殊空白を掃除しつつ、コード部分の「画面上の本当の幅」を計算
	for i, line in ipairs(lines) do
		-- Webコピペ等で混入する特殊な空白(ノーブレークスペース)を通常のスペースに変換
		local clean_line = line:gsub("\xc2\xa0", " ")

		-- 行頭のインデント、コメント記号、中身を分解して取得
		local indent, symbol, content = clean_line:match("^(%s*)([#|])%s*(.*)$")

		if indent then
			-- 独立コメント行の場合：後ろの余分なスペースを削り、綺麗に整形する
			content = content:gsub("%s+$", "") -- 末尾の空白をトリミング
			local new_line = indent .. symbol
			if content ~= "" then
				new_line = new_line .. " " .. content -- 記号の後ろはスペース1個だけに固定
			end
			-- 整形後のラインを上書き対象（rewrite）として登録
			table.insert(parsed, { idx = i, rewrite = new_line })
		else
			-- 「|」を境にコードとコメントに分離（通常のコード＋右側コメントの行）
			local code, comment = clean_line:match("^([^|]-)%s*|%s*(.*)$")
			if code then
				code = code:gsub("%s+$", "") -- コード末尾の余分な空白だけをトリミング

				-- タブ文字 (\t) の幅も考慮して、画面上の正確な表示幅を計算
				local width = vim.fn.strdisplaywidth(code)
				if width > max_width then
					max_width = width
				end
				table.insert(parsed, { idx = i, code = code, comment = comment })
			else
				-- 「|」がない行（loop: や .text など）はそのまま無傷でキープ
				table.insert(parsed, { idx = i, orig = line })
			end
		end
	end

	-- 3. 揃える基準列を決定（最長コードの幅 + 2スペース、最低でも40列目）
	local target_col = math.max(40, max_width + 2)

	-- 4. 2巡目: 計算した位置に合わせてスペースを綺麗に補完して書き換える
	for _, item in ipairs(parsed) do
		if item.code then
			-- 通常のコード＋右側コメント行の整列
			local current_width = vim.fn.strdisplaywidth(item.code)
			local padding = string.rep(" ", target_col - current_width)
			local new_line = item.code .. padding .. "| " .. item.comment
			vim.api.nvim_buf_set_lines(bufnr, item.idx - 1, item.idx, false, { new_line })
		elseif item.rewrite then
			-- 独立コメント行の余分なスペースを削った状態に書き換える
			vim.api.nvim_buf_set_lines(bufnr, item.idx - 1, item.idx, false, { item.rewrite })
		end
	end
end

-- 4. autocmd でファイルを開いたときに実行
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.s", "*.S", "*.asm" },
	callback = function(args)
		local bufnr = args.buf

		-- commentstring 判定
		local arch = detect_asm_arch()
		if arch and asm_comments[arch] then
			vim.bo[bufnr].commentstring = asm_comments[arch]
		else
			-- どれにも引っかからなかった場合のデフォルト（例: x86用の # ）
			vim.bo[bufnr].commentstring = "# %s"
		end

		-- asm 保存時のバッファ書き換えにVimが過剰反応するのを防ぐ
		vim.opt_local.cinkeys:remove("0#")
		vim.opt_local.indentkeys:remove("0#")

		-- | コメント整列（保存時）。| を持たない行は無害。
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				align_pipe_comments(bufnr)
			end,
		})
	end,
})

-- 5. 【救済措置】手動で切り替えるためのユーザーコマンド
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
