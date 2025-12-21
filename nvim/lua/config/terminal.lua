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

return M
