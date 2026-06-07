require("minuet").setup({
	request_timeout = 10,
	provider = "gemini",
	provider_options = {
		openai = {
			model = "gpt-5.4-nano",
			api_key = "OPENAI_API_KEY",
			stream = true,
		},
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
		auto_trigger_ft = {},
		auto_trigger_ignore_ft = { "codecompanion" },
		enable_predicates = {
			function()
				return vim.bo.filetype ~= "codecompanion"
			end,
		},
		keymap = {
			accept = "<A-j>",
			accept_line = "<A-l>",
			next = "<A-n>",
			prev = "<A-p>",
			dismiss = "<A-e>",
		},
	},
})

-- manual trigger
vim.keymap.set("i", "<A-g>", function()
	require("minuet.virtualtext").action.next()
end, { desc = "Minuet AI Show" })
