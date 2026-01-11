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
	{ "nvim-telescope/telescope.nvim", tag = "0.1.5" },

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
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("config.terminal").setup()
		end,
	},

	-- Colorscheme
	{ "sainnhe/sonokai" },

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
		"mfussenegger/nvim-dap",
	},
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

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.expand("~/Downloads/extension/adapter/codelldb"),
					args = { "--port", "${port}" },
				},
			}

			dap.configurations.cpp = {
				{
					name = "Launch C++",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					sourceMap = {
						["/Users/scott/workspace"] = "/Users/scott/Library/CloudStorage/OneDrive-Personal/workspace",
					},
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
	-- dirdiff
	{
		"will133/vim-dirdiff",
	},
	-- vim-fugitive の追加
	{
		"tpope/vim-fugitive",
	},
}
