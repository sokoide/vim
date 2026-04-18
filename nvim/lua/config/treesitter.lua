-- Highlight is built into Neovim 0.10+; just ensure parsers are installed
local ensure_installed = { "c", "cpp", "go", "rust", "python", "lua", "vim", "yaml", "markdown", "markdown_inline" }
for _, lang in ipairs(ensure_installed) do
	vim.cmd("TSInstall " .. lang)
end
