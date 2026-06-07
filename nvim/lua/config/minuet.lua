require("minuet").setup({
	notify = "verbose",
	request_timeout = 30,
	provider = "openai_compatible",
	provider_options = {
		openai = {},
		openai_compatible = {
			model = "deepseek-v4-flash",
			end_point = "https://opencode.ai/zen/go/v1/chat/completions",
			api_key = "OPENCODE_GO_API_KEY",
			name = "opencode-go",
			stream = true,
		},
		gemini = {
			model = "gemini-3.1-flash-lite",
			api_key = "GEMINI_API_KEY",
		},
		anthropic = {
			model = "GLM-4.5-Air",
			api_key = "ANTHROPIC_AUTH_TOKEN",
		},
	},
	virtualtext = {
		auto_trigger_ft = { "lua", "go", "c", "cpp", "python", "javascript", "typescript", "rust", "sh" },
		auto_trigger_ignore_ft = { "codecompanion" },
		enable_predicates = {
			function()
				return vim.bo.filetype ~= "codecompanion"
			end,
		},
		keymap = {
			accept = "<C-f>",
			accept_line = "<C-l>",
			next = "<C-]>",
			prev = "<C-b>",
			dismiss = "<C-e>",
		},
	},
})

-- manual trigger
vim.keymap.set("i", "<A-g>", function()
	require("minuet.virtualtext").action.next()
end, { desc = "Minuet AI Show" })
