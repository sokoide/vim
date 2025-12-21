local overseer = require("overseer")

-- 1. setup は必須
overseer.setup({
	strategy = "terminal",
})

-- 2. make
overseer.register_template({
	name = "make",
	builder = function()
		return {
			cmd = { "make" },
			components = {
				-- { "on_output_quickfix", open = true },
				"default",
			},
		}
	end,
})

-- 3. make run
overseer.register_template({
	name = "make_run",
	builder = function()
		return {
			cmd = { "make", "run" },
			components = {
				-- { "on_output_quickfix", open = true },
				{ "on_output_quickfix", open_on_match = true, error_only = true },
				"default",
			},
		}
	end,
})
