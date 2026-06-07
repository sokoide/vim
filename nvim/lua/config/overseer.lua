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

-----------------------------------------------------
-- Keymaps
-----------------------------------------------------
vim.keymap.set("n", "<leader>rr", "<Cmd>OverseerRun make_run<CR>", { silent = true, desc = "Overseer run" })
vim.keymap.set("n", "<leader>R", "<Cmd>OverseerToggle<CR>", { silent = true, desc = "Overseer toggle" })
vim.keymap.set("n", "<leader>k", function()
	local tasks = overseer.list_tasks({ running = true })
	if #tasks > 0 then
		tasks[1]:stop()
		vim.notify("Task stopped: " .. tasks[1].name)
	else
		vim.notify("No running tasks")
	end
end, { desc = "Kill running Overseer task" })
