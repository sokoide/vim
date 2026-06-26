-- パーサー自動インストール
local ensure_installed = {
	"c", "cpp", "go", "rust", "python",
	"lua", "vim",
	"yaml", "toml",
	"json", "jsonc",
	"typescript", "javascript",
	"html", "css",
	"java", "c_sharp",
	"bash",
	"markdown", "markdown_inline",
	"diff",
	"regex",
	"query",
}
for _, lang in ipairs(ensure_installed) do
	local ok = pcall(vim.treesitter.language.add, lang)
	if not ok then
		vim.cmd("TSInstall " .. lang)
	end
end
