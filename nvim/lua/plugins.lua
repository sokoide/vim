return {
	-- コア
	{ "nvim-lua/plenary.nvim" },

	-- Inline diagnostics (VSCode-like)
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		config = function()
			require("tiny-inline-diagnostic").setup({
				options = {
					show_source = true,
					use_icons_from_diagnostic = true,
					softwrap = 30,
				},
			})
			vim.diagnostic.config({
				virtual_text = false,
				severity_sort = true,
			})
		end,
	},

	-- devicons
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- which-key（キーマップ発見性）
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- surround（括弧・クォート操作）
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = true,
	},

	-- autopairs（括弧の自動閉じ）
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- ファイラー
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
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
		tag = "0.2.1",
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
		build = ":TSUpdate",
		config = function()
			require("config.treesitter")
		end,
	},

	-- tabular
	{ "godlygeek/tabular" },

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"godlygeek/tabular",
		},
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
	{
		"sainnhe/sonokai",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.sonokai_style = "maia"
			vim.g.sonokai_transparent_background = 1
			vim.cmd("colorscheme sonokai")
			-- コメントのイタリックを無効化（テーマの色を維持）
			local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
			comment_hl.italic = false
			vim.api.nvim_set_hl(0, "Comment", comment_hl)
		end,
	},

	-- mason
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			local is_termux = (vim.fn.has("android") == 1) or (os.getenv("ANDROID_ROOT") ~= nil)
			local tools = {
				"asmfmt",
				"gopls",
				"golangci-lint",
				"rust-analyzer",
				"typescript-language-server",
				"jdtls",
				"pyright",
				"eslint-lsp",
				"prettierd",
			}

			if not is_termux then
				table.insert(tools, "asm-lsp")
				-- clangd should be installed already
				-- table.insert(tools, "clangd")
				-- csharp-language-server は AUR 版システムバイナリを使用（lsp.lua の cmd 参照）
				table.insert(tools, "stylua")
				-- ruff: manylinux wheel を pip インストール（非 Termux 環境）
				table.insert(tools, "ruff")
			else
				-- Termux は ruff の wheel が無く mason/pip で失敗するため、
				-- `pkg install ruff` のシステムバイナリを使用（lsp.lua / conform.lua は PATH の ruff を参照）
			end

			require("mason-tool-installer").setup({
				ensure_installed = tools,
				auto_update = true,
				run_on_start = true,
			})
		end,
	},

	-- formatter
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
				backends = { "asm", "lsp", "treesitter", "markdown" },
				layout = {
					max_width = 0.3,
					min_width = 20,
					default_direction = "right",
				},
				show_guides = true,
			})
		end,
	},

	-- DAP
	{
		"leoluz/nvim-dap-go",
		ft = "go",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			if vim.fn.filereadable(vim.fn.getcwd() .. "/.vscode/launch.json") == 0 then
				require("dap-go").setup()
			end
			dap.adapters.go = {
				type = "server",
				port = "${port}",
				executable = {
					command = "dlv",
					args = {
						"dap",
						"-l",
						"127.0.0.1:${port}",
						"--check-go-version=false",
						"--only-same-user=false",
					},
				},
				options = {
					initialize_timeout_sec = 20,
				},
			}
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
			require("config.dap")
		end,
	},
	{
		"stevearc/resession.nvim",
		config = function()
			require("resession").setup({
				buffers = {
					skip_unlisted = false,
				},
			})
		end,
	},

	-- LSP progress indicator
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {},
	},

	-- Lspsaga
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
			})
		end,
	},

	-- Overseer
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
			require("config.codecompanion")
		end,
	},

	-- AI Completion / Suggestion
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("config.minuet")
		end,
	},

	-- Completion UI
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			require("config.cmp")
		end,
	},

	-- dirdiff
	{
		"will133/vim-dirdiff",
	},

	-- Markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	{
		"dhruvasagar/vim-table-mode",
		ft = { "markdown" },
		init = function()
			vim.g.table_mode_corner = "|"
			vim.g.table_mode_header_fillchar = "-"
		end,
		config = function()
			require("config.tablemode")
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && (pnpm install || npm install) && (pnpm add msgpack-lite || npm install msgpack-lite) && git checkout .",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("config.gitsigns")
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			require("config.todo-comments")
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("config.trouble")
		end,
	},
	{
		"tpope/vim-fugitive",
	},
}
