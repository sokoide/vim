return {
	-- コア
	{ "nvim-lua/plenary.nvim" },

	-- devicons
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- ファイラー
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- devicon 必須
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("config.neo-tree")
		end,
	},

	-- ステータスライン
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("config.lualine")
		end,
	},

	-- ノーティフィケーション強化
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		config = function()
			require("config.noice")
		end,
	},

	-- Telescope（fzf代替）
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		config = function()
			require("telescope").setup({})
			require("telescope").load_extension("ui-select")
		end,
		dependencies = {
			"nvim-telescope/telescope-ui-select.nvim",
		},
	},

	-- Treesitter（Syntaxと構造解析）
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("config.treesitter")
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("config.lsp")
		end,
	},

	-- Terminal（Codex常駐用）
	-- {
	-- 	"akinsho/toggleterm.nvim",
	-- 	version = "*",
	-- 	config = function()
	-- 		require("config.terminal").setup()
	-- 	end,
	-- },

	-- Colorscheme
	{
		"sainnhe/sonokai",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.sonokai_style = "maia"
			vim.g.sonokai_enable_italic = true
			vim.cmd("colorscheme sonokai")
		end,
	},

	-- golangci-lint=langserver
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup()
		end,
	},

	-- formatter
	-- Formatter framework
	{
		"stevearc/conform.nvim",
		config = function()
			require("config.conform")
		end,
	},
	-- Aerial
	{
		"stevearc/aerial.nvim",
		config = function()
			require("aerial").setup({
				backends = { "lsp", "treesitter", "markdown" },
				layout = {
					max_width = 0.3,
					min_width = 20,
					default_direction = "right",
				},
				show_guides = true,
			})
		end,
	},
	-- nvim-dap
	{
		"leoluz/nvim-dap-go",
		ft = "go",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
			require("dap-go").setup()
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			require("dapui").setup()
		end,
	},
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			dap.adapters.lldb = {
				type = "executable",
				command = "/data/data/com.termux/files/usr/bin/lldb-dap",
				name = "lldb",
			}

			dap.configurations.cpp = {
				{
					name = "Launch C++",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}

			-- C も C++ と同じ設定を共有
			dap.configurations.c = dap.configurations.cpp
		end,
	},
	-- lspsaga
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("lspsaga").setup({
				lightbulb = {
					enable = false,
				},
				ui = {
					-- code_action = "💡",
				},
			})
		end,
	},

	-- overseer
	{
		"stevearc/overseer.nvim",
		config = function()
			require("config.overseer")
		end,
	},
	-- AI Chat / Inline editing (CodeCompanion)
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("codecompanion").setup({
				adapters = {
					http = {
						anthropic = function()
							return require("codecompanion.adapters").extend("anthropic", {
								env = { api_key = "ANTHROPIC_AUTH_TOKEN" },
								url = (vim.env.ANTHROPIC_BASE_URL or "https://api.anthropic.com") .. "/v1/messages",
								schema = { model = { default = "claude-3-5-sonnet-latest" } },
							})
						end,
						gemini = function()
							return require("codecompanion.adapters").extend("gemini", {
								env = { api_key = "GEMINI_API_KEY" },
								schema = { model = { default = "gemini-2.0-flash" } },
							})
						end,
						openai = function()
							return require("codecompanion.adapters").extend("openai", {
								env = { api_key = "OPENAI_API_KEY" },
								schema = { model = { default = "gpt-4o" } },
							})
						end,
					},
				},
				interactions = {
					chat = { adapter = "gemini" },
					inline = { adapter = "gemini" },
					cmd = { adapter = "gemini" },
				},
			})

			-- Generic actions
			vim.keymap.set(
				{ "n", "v" },
				"<leader>aa",
				"<cmd>CodeCompanionActions<CR>",
				{ silent = true, desc = "AI Actions" }
			)

			-- Specific Chats (Lua API to ensure correct adapter)
			vim.keymap.set("n", "<leader>aic", function()
				require("codecompanion").chat({ params = { adapter = "anthropic" } })
			end, { silent = true, desc = "AI Chat (Claude)" })
			vim.keymap.set("n", "<leader>aig", function()
				require("codecompanion").chat({ params = { adapter = "gemini" } })
			end, { silent = true, desc = "AI Chat (Gemini API)" })
			vim.keymap.set("n", "<leader>ail", function()
				require("codecompanion").chat({ params = { adapter = "gemini_cli" } })
			end, { silent = true, desc = "AI Chat (Gemini Login)" })
			vim.keymap.set("n", "<leader>aix", function()
				require("codecompanion").chat({ params = { adapter = "openai" } })
			end, { silent = true, desc = "AI Chat (ChatGPT)" })

			-- Visual mode Chat Add
			vim.keymap.set("v", "<leader>aic", function()
				require("codecompanion").chat({ params = { adapter = "anthropic" } })
			end, { silent = true, desc = "AI Chat Add (Claude)" })
			vim.keymap.set("v", "<leader>aig", function()
				require("codecompanion").chat({ params = { adapter = "gemini" } })
			end, { silent = true, desc = "AI Chat Add (Gemini API)" })
			vim.keymap.set("v", "<leader>ail", function()
				require("codecompanion").chat({ params = { adapter = "gemini_cli" } })
			end, { silent = true, desc = "AI Chat Add (Gemini Login)" })
			vim.keymap.set("v", "<leader>aix", function()
				require("codecompanion").chat({ params = { adapter = "openai" } })
			end, { silent = true, desc = "AI Chat Add (ChatGPT)" })

			-- Inline mapping
			vim.keymap.set("n", "<leader>an", "<cmd>CodeCompanion<CR>", { silent = true, desc = "AI Inline" })
		end,
	},
	-- AI Completion / Suggestion
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("minuet").setup({
				provider = "gemini",
				provider_options = {
					openai = {
						model = "gpt-4o",
						api_key = "OPENAI_API_KEY",
					},
					gemini = {
						model = "gemini-1.5-flash",
						api_key = "GEMINI_API_KEY",
					},
					anthropic = {
						model = "claude-3-5-sonnet-20240620",
						api_key = "ANTHROPIC_AUTH_TOKEN",
					},
				},
				virtualtext = {
					auto_trigger_ft = { "lua", "go", "python", "javascript", "typescript", "cpp", "c" },
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
		end,
	},
	-- Completion UI (includes Minuet source)
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"milanglacier/minuet-ai.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local ok_minuet, minuet = pcall(require, "minuet")
			if ok_minuet then
				cmp.register_source("minuet", require("minuet.cmp"):new())
			end

			local sources = {
				{ name = "buffer" },
				{ name = "path" },
			}
			if ok_minuet then
				table.insert(sources, 1, { name = "minuet" })
			end

			cmp.setup({
				completion = {
					autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-e>"] = cmp.mapping.abort(),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources(sources),
			})

			-- Disable cmp entirely for CodeCompanion chat buffers
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "codecompanion",
				callback = function()
					cmp.setup.buffer({ enabled = false })
				end,
			})
		end,
	},
	-- dirdiff
	{
		"will133/vim-dirdiff",
	},
	-- vim-fugitive の追加
	{
		"tpope/vim-fugitive",
	},
}
