vim.cmd("TableModeEnable")

-- ============================================================
-- Markdown テーブル行の折り返しヘルパ
-- 表示幅が max_width (既定80) を超える行を見つけ、最も長いセルを
-- 単語境界で分割して 2 行にする。2 行目は分割したセル以外を空にする。
-- <br> は使わない。冪等(折り返し後は全行 <= max_width になる)。
-- ============================================================

-- 行をパイプで分割し、各セルをトリムして返す(外側のパイプは除く)。
local function get_cells(line)
	local s = line:gsub("^%s*", ""):gsub("%s*$", "")
	s = s:gsub("^|", ""):gsub("|$", "")
	local cells = {}
	for c in (s .. "|"):gmatch("([^|]*)|") do
		table.insert(cells, (c:gsub("^%s*", ""):gsub("%s*$", "")))
	end
	return cells
end

-- markdown のセパレータ行か(全セルが :--- / --- / ---: の形式)。
local function is_separator_row(line)
	if not line:match("^%s*|") then
		return false
	end
	local cells = get_cells(line)
	if #cells == 0 then
		return false
	end
	for _, c in ipairs(cells) do
		if not c:match("^:?%-+:?$") then
			return false
		end
	end
	return true
end

local function is_table_row(line)
	return line:match("^%s*|") ~= nil
end

local function build_row(cells)
	return "| " .. table.concat(cells, " | ") .. " |"
end

-- 表示幅が最大のセルのインデックス(同幅なら最初)。
local function longest_cell_index(cells)
	local bi, bw = 1, -1
	for i, c in ipairs(cells) do
		local w = vim.fn.strdisplaywidth(c)
		if w > bw then
			bi, bw = i, w
		end
	end
	return bi
end

-- text を「first の表示幅が avail 以下」になるよう分割する。
-- avail 以内の最後の空白で切る。空白がなければ avail を超える文字で強制切断。
-- 戻り値: first, rest (text が収まるなら rest == "")。
local function split_cell_at(text, avail)
	if avail < 1 or vim.fn.strdisplaywidth(text) <= avail then
		return text, ""
	end
	local n = vim.fn.strchars(text)
	local width = 0
	local last_space = -1
	local cut = n
	for i = 0, n - 1 do
		local ch = vim.fn.strcharpart(text, i, 1)
		local cw = vim.fn.strdisplaywidth(ch)
		if width + cw > avail then
			cut = i
			break
		end
		width = width + cw
		if ch == " " then
			last_space = i
		end
		cut = i + 1
	end
	local sep = last_space >= 1 and last_space or cut
	local first = vim.fn.strcharpart(text, 0, sep):gsub("%s+$", "")
	local rest = vim.fn.strcharpart(text, sep):gsub("^%s+", "")
	return first, rest
end

-- max_width を超えるテーブル行を折り返す。
-- ヘッダ行(テーブルブロックの先頭行)は整列/境界検出を壊さないよう折り返さない。
local function wrap_all_long_rows(max_width)
	max_width = max_width or 80
	-- strdisplaywidth は &ambiwidth の影響を受ける。日本語環境などで
	-- ambiwidth=double だと曖昧幅文字(〜ー｜→－☆ 等)が幅2に過大計上され、
	-- 表示幅80以下の行まで折り返されてしまう。測定中だけ single に固定し、
	-- 終了後（エラー時含む）必ず元に戻す。
	local saved_ambiwidth = vim.o.ambiwidth
	local ok, err = pcall(function()
		vim.o.ambiwidth = "single"
	local cur = 1
	while cur <= vim.fn.line("$") do
		local line = vim.fn.getline(cur)
		if not is_table_row(line) then
			cur = cur + 1
		elseif is_separator_row(line) then
			cur = cur + 1
		elseif vim.fn.strdisplaywidth(line) <= max_width then
			cur = cur + 1
		else
			local prev = cur > 1 and vim.fn.getline(cur - 1) or ""
			if not is_table_row(prev) then
				-- ヘッダ行は折り返さない
				cur = cur + 1
			else
				local cells = get_cells(line)
				local idx = longest_cell_index(cells)
				local sk = { unpack(cells) }
				sk[idx] = ""
				local avail = max_width - vim.fn.strdisplaywidth(build_row(sk))
				local first, rest = split_cell_at(cells[idx], avail)
				if avail < 1 or rest == "" then
					cur = cur + 1
				else
					local row1 = { unpack(cells) }
					row1[idx] = first
					local row2 = {}
					for i = 1, #cells do
						row2[i] = (i == idx) and rest or ""
					end
					vim.fn.setline(cur, build_row(row1))
					vim.fn.append(cur, build_row(row2))
					-- row1 は確実に <= max_width になるので次行(row2)へ
					cur = cur + 1
				end
			end
		end
	end
	end)
	vim.o.ambiwidth = saved_ambiwidth
	if not ok then
		error(err)
	end
end

-- カレントバッファの全テーブルを折り返し + 整列
-- 折り返してから整列すれば、列幅が1回の Realign で確定する。
vim.api.nvim_create_user_command("MdTableAlignAll", function()
	local winview = vim.fn.winsaveview()

	wrap_all_long_rows(80)

	local total = vim.fn.line("$")
	local cur = 1
	while cur <= total do
		if vim.fn.getline(cur):match("^%s*|") then
			-- テーブル先頭行にカーソルを移動
			-- 1回だけ呼ぶ(TableModeRealign はテーブル全体を処理する)
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
end, { desc = "Wrap long rows + realign all markdown tables in buffer" })
