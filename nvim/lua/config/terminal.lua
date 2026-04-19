local M = {}

function M.setup()
	require("toggleterm").setup({
		size = 18,
		open_mapping = [[<c-\>]],
		direction = "horizontal",
		persist_mode = true,
	})
end

-- Codex専用ターミナル（常駐）
local codex = nil
local gemini = nil
local claude = nil

function M.toggle_codex()
	if not codex then
		codex = require("toggleterm.terminal").Terminal:new({
			cmd = "codex",
			direction = "float",
			float_opts = { border = "curved" },
			hidden = true,
		})
	end
	codex:toggle()
end

function M.toggle_gemini()
	if not gemini then
		gemini = require("toggleterm.terminal").Terminal:new({
			cmd = "gemini",
			direction = "float",
			float_opts = { border = "curved" },
			hidden = true,
		})
	end
	gemini:toggle()
end

function M.toggle_claude()
	if not claude then
		claude = require("toggleterm.terminal").Terminal:new({
			cmd = "claude",
			direction = "float",
			float_opts = { border = "curved" },
			hidden = true,
		})
	end
	claude:toggle()
end

return M
