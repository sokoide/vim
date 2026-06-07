local cmp = require("cmp")

cmp.setup({
	completion = {
		autocomplete = false,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-y>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<C-e>"] = cmp.mapping.abort(),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	sources = cmp.config.sources({
		{ name = "buffer" },
		{ name = "path" },
	}),
})

-- Disable cmp for CodeCompanion chat buffers
vim.api.nvim_create_autocmd("FileType", {
	pattern = "codecompanion",
	callback = function(ev)
		cmp.setup.buffer({ enabled = false })
	end,
})
