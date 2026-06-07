# AGENTS.md — vim (Neovim config)

## Deploy

```sh
make install   # rsync nvim/ → ~/.config/nvim/ + cp ~/.prettierrc.json
```

Termux uses `rm -rf` / `cp -r` instead of rsync (not available on Android).

## Entrypoint & structure

- `nvim/init.lua` — bootstrap lazy.nvim, load plugins, basic settings, clipboard, file watcher, autocmds (~150 lines)
- `nvim/lua/plugins.lua` — all plugins + most inline config (~580 lines, this is the main config file)
- `nvim/lua/config/*.lua` — per-plugin config files loaded from plugins.lua or init.lua
  - `keymap.lua` — 汎用キーマップ（plugin非依存: buffer, window, Telescope, Go test, Fugitive, gx）
  - `lsp.lua` — 全LSP関連キーマップ（native + Saga + diagnostics + Telescope LSP）
  - `dap.lua` — DAP adapter設定 + sign定義 + 全DAPキーマップ
  - `terminal.lua` — toggleterm設定 + terminal toggleキーマップ
  - `overseer.lua` — overseer template + タスク実行キーマップ
  - `asm.lua` — asm comment arch detection + `:AsmArch` command
  - `diff.lua` — diff mode wrap enforcement
- `conductor/` — planning docs for ongoing work (read before making structural changes)

## キーマップ配置ルール

| 配置先 | 基準 |
|---|---|
| `keymap.lua` | plugin非依存の汎用マップ（Vimコマンド・Neovim built-in APIのみ） |
| `config/<name>.lua` | その機能ドメインのキーマップ + 設定 |
| `plugins.lua` | プラグインconfigに密結合したマップ（adapter選択などplugin APIを直接呼ぶもの） |
| `lsp.lua` | 全LSP関連マップ（native + Saga + diagnostics） |
- `conductor/` — planning docs for ongoing work (read before making structural changes)

## API keys

Loaded from `~/.glm` (shell `export VAR=value` format):
- `ANTHROPIC_AUTH_TOKEN` — for litellm/anthropic adapters AND the `z.ai` Minuet backend
- `ANTHROPIC_BASE_URL` — optional, for custom endpoint
- `GEMINI_API_KEY` — for gemini adapters and Minuet gemini backend
- `OPENAI_API_KEY` — for openai adapter

Neovim bootstrap reads them at the top of `init.lua`. AI features (CodeCompanion, Minuet) will silently fail if `~/.glm` is missing.

## Leader key

**Not changed — default `\`.** So `<leader>ff` = `\ff`.

## Key quirks

- `<C-e>e` — Neo-tree toggle (not `<C-n>` or `<leader>e`)
- `<A-f>` — Minuet AI manual trigger (auto_trigger_ft is empty, completion is always manual)
- `nvim-cmp` autocomplete is disabled — `<C-y>` triggers completion manually
- `<leader>md` toggles RenderMarkdown AND runs `MdTableAlignAll`
- `<leader>rr` runs overseer (was `<leader>r` — changed to avoid prefix conflict with `<leader>rn`)
- `q` closes quickfix/help/man/lspinfo/Trouble/toggleterm buffers

## CodeCompanion adapters

All adapters are nested under `adapters.http` (non-standard). The default strategy adapter is `litellm` → local `http://localhost:4000`. Keymaps call each adapter by name explicitly:

| Key | Adapter |
|-----|---------|
| `<leader>aic` | litellm |
| `<leader>aig` | gemini |
| `<leader>ail` | gemini_cli |
| `<leader>aix` | openai_chatgpt |

## Neovim 0.12.1 treesitter bug workaround

Two functions are monkey-patched to prevent crashes on `codecompanion` filetype buffers (in the CodeCompanion plugin config):
- `vim.treesitter.start` — no-ops for codecompanion buffers
- `vim.treesitter.get_range` — guards against nil node

## Termux detection

Used in two places:
- `init.lua`: sets `TMPDIR` and `XDG_RUNTIME_DIR` (Android has no `/tmp`)
- `plugins.lua` (mason-tool-installer): skips asm-lsp, clangd, csharp-ls, stylua

## LSP

Configured via the modern `vim.lsp.config()` API (neovim 0.11+), not `lspconfig` setup function.
All formatters are disabled at the LSP level (`on_attach` sets `documentFormattingProvider = false`) and delegated to `conform.nvim` instead.

## Format-on-save (conform.nvim)

Runs `format_on_save` for most filetypes. **Explicitly excludes** `sh` / `bash` / `zsh`.
Formatter configs: clang-format reads `--style=file`, prettier/prettierd reads `~/.prettierrc.json`.

## DAP

- Go: `dlv dap` with `--check-go-version=false --only-same-user=false`
- C/C++: `lldb-dap` (Homebrew path `/opt/homebrew/opt/llvm/bin/lldb-dap` on macOS, `/data/data/com.termux/files/usr/bin/lldb-dap` on Termux)
- iCloud Drive paths are remapped (`/Users/scott/Library/CloudStorage/OneDrive-Personal/` → `/Users/scott/`) on setBreakpoints
- `.vscode/launch.json` takes precedence; static config only registered if that file is absent

## Clipboard

Uses OSC 52 (not system clipboard). Important for SSH/TMUX sessions — `pbcopy`/`xclip` are NOT used.

## File watcher

`vim.uv.new_fs_event()` watches each file on open + `FocusGained`/`CursorHold`/`BufEnter` triggers `checktime`. Good for external edits (git pull, rebase, etc.).

## Asm comment detection

When opening `.s` / `.S` files, detects architecture from path or register patterns:
`m68k` → `| ` / `x86` → `# ` / `aarch32` → `@ ` / `aarch64` → `// `
Override with `:AsmArch {name}` (tab-completion for the 4 arch names).

## LSP references map

- `gr` — Lspsaga finder (rich UI)
- `gR` — `vim.lsp.buf.references` (native)
- `<leader>fr` — Telescope lsp_references (aliased for clarity)

## Custom commands

- `:MdTableAlignAll` — finds all markdown table blocks in buffer and realigns them. **Does not work in headless mode** (known issue — `strdisplaywidth` behaves differently due to `ambiwidth` detection).
- `:AsmArch {name}` — manually set asm comment char per architecture.

## Known WIP / ongoing

- `MdTableAlignAll` headless-mode failure — see `.ai-handoff.md` and `test_table.md` (test fixture)
- `plugins.lua.bak` is a stale backup; the live file is `plugins.lua`

## Conventions

- Commits: short informal messages, mixed English/Japanese, no strict semantic prefix convention
- Comments in config: Japanese
- No test framework; `~/test_table.md` is an ad-hoc test fixture
- `.gitignore` ignores `.serena/`, swap files, backups, undo history, netrwhist, tags

## Deploy caveats

`Makefile` runs `rsync --delete` — removes files in `~/.config/nvim/` not present in source. Do NOT modify files under `~/.config/nvim/` directly unless you are okay with them being wiped on next `make install`.
