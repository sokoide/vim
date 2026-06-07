require("minuet").setup({
	provider = "openai_compatible",
	provider_options = {
		openai = {},
		openai_compatible = {
			model = "GLM-4.5-Air",
			end_point = "https://api.z.ai/api/coding/paas/v4/chat/completions",
			api_key = "ANTHROPIC_AUTH_TOKEN",
			name = "z.ai",
		},
		gemini = {
			model = "gemini-3.1-flash-lite",
			api_key = "GEMINI_API_KEY",
		},
		anthropic = {
			-- model = "claude-3-5-sonnet-20240620",
			model = "GLM-4.5-Air",
			api_key = "ANTHROPIC_AUTH_TOKEN",
		},
	},
	virtualtext = {
		-- auto_trigger_ft = { "lua", "python", "javascript", "typescript", "rust", "go", "c", "cpp" },
		auto_trigger_ft = {},
		auto_trigger_ignore_ft = { "codecompanion" },
		enable_predicates = {
			function()
				return vim.bo.filetype ~= "codecompanion"
			end,
		},
		keymap = {
			accept = "<A-y>",
			accept_line = "<A-l>",
			next = "<A-]>",
			prev = "<A-[>",
			dismiss = "<A-e>",
		},
	},
})

-- manual trigger
vim.keymap.set("i", "<A-f>", function()
	require("minuet.virtualtext").action.next()
end, { desc = "Minuet AI Show" })
