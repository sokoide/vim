require("codecompanion").setup({
	adapters = {
		http = {
			anthropic = function()
				return require("codecompanion.adapters").extend("anthropic", {
					env = { api_key = "ANTHROPIC_AUTH_TOKEN" },
					schema = { model = { default = "claude-3-5-sonnet-latest" } },
				})
			end,
			gemini = function()
				return require("codecompanion.adapters").extend("gemini", {
					env = { api_key = "GEMINI_API_KEY" },
					schema = { model = { default = "gemini-3.1-flash-lite" } },
				})
			end,
			gemini_cli = function()
				return require("codecompanion.adapters").extend("gemini", {
					env = { api_key = "GEMINI_API_KEY" },
					schema = { model = { default = "gemini-3.1-flash-lite" } },
				})
			end,
			openai_chatgpt = function()
				return require("codecompanion.adapters").extend("openai", {
					env = { api_key = "OPENAI_API_KEY" },
					schema = { model = { default = "gpt-4o" } },
				})
			end,
			zai = function()
				return require("codecompanion.adapters").extend("openai", {
					env = { api_key = "ANTHROPIC_AUTH_TOKEN" },
					url = "https://api.z.ai/api/coding/paas/v4/chat/completions",
					schema = {
						model = {
							default = "GLM-4.7",
						},
					},
				})
			end,
			litellm = function()
				return require("codecompanion.adapters").extend("openai", {
					env = { api_key = "dummy" },
					url = "http://localhost:4000/v1/chat/completions",
					schema = {
						model = {
							default = "sonnet",
						},
					},
					temperature = {
						enabled = false, -- 最新バージョン(v18以降)向け
						condition = function()
							return false
						end, -- 以前のバージョン向け
					},
					top_p = {
						enabled = false,
						condition = function()
							return false
						end,
					},
				})
			end,
			opencode_go = function()
				return require("codecompanion.adapters").extend("openai", {
					env = { api_key = "OPENCODE_GO_API_KEY" },
					url = "https://opencode.ai/zen/go/v1/chat/completions",
					schema = { model = { default = "deepseek-v4-flash" } },
				})
			end,
			opencode_go_pro = function()
				return require("codecompanion.adapters").extend("openai", {
					env = { api_key = "OPENCODE_GO_API_KEY" },
					url = "https://opencode.ai/zen/go/v1/chat/completions",
					schema = { model = { default = "deepseek-v4-pro" } },
				})
			end,
		},
	},
	strategies = {
		chat = { adapter = "opencode_go" },
		inline = { adapter = "opencode_go" },
		cmd = { adapter = "opencode_go" },
	},
	display = {
		chat = {
			window = {
				layout = "vertical",
				width = 0.4,
			},
		},
		diff = {
			provider = "native",
		},
	},
	opts = {
		log_level = "DEBUG",
	},
})

-- Generic actions
vim.keymap.set(
	{ "n", "v" },
	"<leader>aa",
	"<Cmd>CodeCompanionActions<CR>",
	{ silent = true, desc = "AI Actions" }
)

-- Specific Chats (Lua API to ensure correct adapter)
vim.keymap.set("n", "<leader>aio", function()
	require("codecompanion").chat({ params = { adapter = "opencode_go" } })
end, { silent = true, desc = "AI Chat (OpenCode Go Flash)" })
vim.keymap.set("n", "<leader>aiO", function()
	require("codecompanion").chat({ params = { adapter = "opencode_go_pro" } })
end, { silent = true, desc = "AI Chat (OpenCode Go Pro)" })
vim.keymap.set("n", "<leader>aic", function()
	require("codecompanion").chat({ params = { adapter = "litellm" } })
end, { silent = true, desc = "AI Chat (Claude)" })
vim.keymap.set("n", "<leader>aig", function()
	require("codecompanion").chat({ params = { adapter = "gemini" } })
end, { silent = true, desc = "AI Chat (Gemini API)" })
vim.keymap.set("n", "<leader>ail", function()
	require("codecompanion").chat({ params = { adapter = "gemini_cli" } })
end, { silent = true, desc = "AI Chat (Gemini Login)" })
vim.keymap.set("n", "<leader>aix", function()
	require("codecompanion").chat({ params = { adapter = "openai_chatgpt" } })
end, { silent = true, desc = "AI Chat (ChatGPT)" })

-- Visual mode Chat Add
vim.keymap.set("v", "<leader>aio", function()
	require("codecompanion").chat({ params = { adapter = "opencode_go" } })
end, { silent = true, desc = "AI Chat Add (OpenCode Go Flash)" })
vim.keymap.set("v", "<leader>aiO", function()
	require("codecompanion").chat({ params = { adapter = "opencode_go_pro" } })
end, { silent = true, desc = "AI Chat Add (OpenCode Go Pro)" })
vim.keymap.set("v", "<leader>aic", function()
	require("codecompanion").chat({ params = { adapter = "litellm" } })
end, { silent = true, desc = "AI Chat Add (Claude)" })
vim.keymap.set("v", "<leader>aig", function()
	require("codecompanion").chat({ params = { adapter = "gemini" } })
end, { silent = true, desc = "AI Chat Add (Gemini API)" })
vim.keymap.set("v", "<leader>ail", function()
	require("codecompanion").chat({ params = { adapter = "gemini_cli" } })
end, { silent = true, desc = "AI Chat Add (Gemini Login)" })
vim.keymap.set("v", "<leader>aix", function()
	require("codecompanion").chat({ params = { adapter = "openai_chatgpt" } })
end, { silent = true, desc = "AI Chat Add (ChatGPT)" })

-- Inline mapping
vim.keymap.set("n", "<leader>an", "<Cmd>CodeCompanion<CR>", { silent = true, desc = "AI Inline" })
vim.keymap.set("v", "<leader>an", "<Cmd>CodeCompanion<CR>", { silent = true, desc = "AI Inline (visual)" })

-- Neovim 0.12.1 treesitter bug workarounds
local _ts_start = vim.treesitter.start
vim.treesitter.start = function(buf, ...)
	if vim.bo[buf or 0].filetype == "codecompanion" then
		return
	end
	return _ts_start(buf, ...)
end
local _ts_get_range = vim.treesitter.get_range
vim.treesitter.get_range = function(node, source, metadata)
	if node == nil then
		return { 0, 0, 0, 0 }
	end
	return _ts_get_range(node, source, metadata)
end
