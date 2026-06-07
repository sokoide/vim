# Neovim 設定 README

このプロジェクトの Neovim 設定に含まれる主要なプラグインと、その使い方をまとめたガイドです。

## 概要

本設定では、開発効率を向上させるために以下の主要カテゴリのプラグインが導入されています。

### カテゴリ別プラグイン一覧

| カテゴリ         | プラグイン名                                    | 概要                                 |
| :---             | :---                                            | :---                                 |
| **ファイラー**   | `neo-tree.nvim`                                 | ファイルツリーエクスプローラー。     |
| **Outline**      | `aerial.nvim`                                   | 関数・クラス構造のシンボル一覧表示。 |
| **検索**         | `telescope.nvim`                                | ファイル検索、Grep、シンボル検索。   |
| **LSP管理**      | `nvim-lspconfig`, `mason`                       | 言語サーバーの管理。                 |
| **シンタックス** | `nvim-treesitter`                               | コード構造解析・ハイライト。         |
| **デバッグ**     | `nvim-dap`                                      | デバッガー。                         |
| **AI統合**       | `codecompanion.nvim`                            | AIチャット/インラインコード編集。    |
| **AI補完**       | `minuet-ai.nvim`                                | AIによるコード自動補完。             |
| **UI強化**       | `noice.nvim`                                    | 通知やコマンドラインの視覚的強化。   |
| **Git**          | `vim-fugitive`                                  | Gitコマンド操作・Diff確認。          |
| **タスク実行**   | `overseer.nvim`                                 | タスクランナー。                     |
| **補完UI**       | `nvim-cmp`                                      | 補完メニューの表示管理。             |
| **Markdown**     | `render-markdown.nvim`, `markdown-preview.nvim` | 編集画面・ブラウザでのプレビュー。   |

---

## 主要なキーバインド

日常的な開発で頻繁に使用するキーマップです。

### 基本操作・ウィンドウ
*   **ファイルツリー切り替え**: `<C-e>e`
*   **コードアウトライン表示**: `<leader>ao`
*   **ウィンドウ移動**: `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`
*   **ウィンドウ幅リサイズ**: `<leader>+` (増), `<leader>-` (減)
*   **バッファ切り替え**: `<C-p>` (前), `<C-n>` (次)
*   **Quickfixを開く**: `<leader>q`
*   **Neovim終了**: `<leader>]`
*   **カーソル下のURLを開く**: `gx`

### LSP / 診断 (Diagnostics)
行番号の横に表示される `W` (Warning) や `E` (Error) の詳細を確認する操作です。

**定義移動:**
*   **定義へジャンプ**: `gd`
*   **宣言へジャンプ**: `gD`
*   **実装へジャンプ**: `gi`
*   **型定義へジャンプ**: `gy`
*   **ホバー表示**: `K`

**Lspsaga (リッチUI):**
*   **参照/定義ファインダー**: `gr`
*   **定義を覗き見**: `gp`
*   **リネーム**: `<leader>rn`
*   **コードアクション**: `<leader>ca`

**診断ナビゲーション:**
*   **診断をフロート表示**: `gl` (カーソル位置), `<leader>h` (行全体)
*   **次/前の診断へジャンプ**: `]d`, `[d`
*   **エラー一覧をQuickfixで表示**: `<leader>e`
*   **警告一覧をQuickfixで表示**: `<leader>w`
*   **LSP参照一覧**: `gR` または `<leader>fr`

### 検索 (Telescope)
*   **ファイル検索**: `<leader>ff` (カーソル下のワードで検索)
*   **Live Grep**: `<leader>fg` (カーソル下のワードで検索)
*   **バッファ検索**: `<leader>fb`
*   **ドキュメント内シンボル**: `<leader>fs`
*   **ワークスペース内シンボル**: `<leader>fS`

### AI アシスト (CodeCompanion)
*   **AI アクションメニュー**: `<leader>aa`
*   **AI チャット (Opencode Go)**: `<leader>aio`
*   **AI チャット (Opencode Go Pro)**: `<leader>aiO`
*   **AI チャット (Claude)**: `<leader>aic`
*   **AI チャット (Gemini API)**: `<leader>aig`
*   **AI チャット (Gemini Login)**: `<leader>ail`
*   **AI チャット (ChatGPT)**: `<leader>aix`
*   **AI インライン生成**: `<leader>an` (ノーマル/ビジュアルモード両対応)

### AI 補完 (Minuet AI)
*   **手動トリガー**: `<C-g>` (**g**enerate)
*   **補完採用**: `<C-f>` (**f**inish)
*   **行採用**: `<C-l>` (**l**ine)
*   **次の候補**: `<C-]>` (forward)
*   **前の候補**: `<C-b>` (**b**ack)
*   **破棄**: `<C-e>` (**e**nd)

### 補完UI (nvim-cmp)
*   **補完完了**: `<C-y>`
*   **確定**: `<CR>`
*   **中止**: `<C-e>`
*   **次/前のアイテム**: `<Tab>`, `<S-Tab>`

### AI CLI (Overlay Terminal)
*   **Codex Terminal**: `<leader>ct`
*   **Gemini CLI**: `<leader>ag`
*   **Claude CLI**: `<leader>ac`

### Go 開発関連
*   **テスト (関数単位)**: `<leader>tf` (カーソル下の Test 関数を実行)
*   **テスト (ファイル単位)**: `<leader>tt`
*   **テスト (全パッケージ)**: `<leader>ta`
*   **make実行**: `<leader>ma` (Quickfixで結果表示)

### タスク実行 (Overseer)
*   **タスク実行 (選択)**: `<leader>rr`
*   **タスク一覧表示**: `<leader>R`
*   **実行中タスクの停止**: `<leader>k`

### デバッグ (DAP)
*   **実行/継続**: `<F5>` / `<A-r>`
*   **ブレークポイント切り替え**: `<F9>` / `<A-b>`
*   **ステップオーバー / イン / アウト**: `<F10>` / `<A-;>`, `<F11>` / `<A-'>`, `<F12>` / `<A-/>`
*   **REPL表示**: `<leader>dr`
*   **ペイン最大化/復元**: `<leader>du`
*   **デバッグ停止**: `<leader>dt`

### Git 操作 (Fugitive)
*   **Git Diff (Index)**: `<leader>gd` (`:Gvdiffsplit` - 垂直分割)
*   **Git Diff (HEAD)**: `<leader>gh` (`:Gvdiffsplit HEAD` - 垂直分割)

### Markdown
*   **RenderMarkdown 切り替え + テーブル整列**: `<leader>md`
*   **ブラウザプレビュー**: `:MarkdownPreviewToggle`

---

## キーマップの仕組み

### `<leader>` キー

本設定では `mapleader` を変更していないため、デフォルトの `\` が leader です。例: `<leader>ff` → `\ff`

### `silent = true` について

キーマップの opts に付けている `silent = true` は、キー押下時にコマンドラインへ実行コマンドをエコーしないようにするオプションです。

```
-- silent なし: 画面下に :Gvdiffsplit<CR> が一瞬表示される
vim.keymap.set("n", "<leader>gd", ":Gvdiffsplit<CR>")

-- silent あり: 何も表示されず、結果だけが即座に現れる
vim.keymap.set("n", "<leader>gd", ":Gvdiffsplit<CR>", { silent = true })
```

`function() ... end` を割り当てているキーマップ（Telescope、DAP、Go test など）は、そもそもコマンドラインにエコーされないため `silent` の有無で違いはありません。

### `noremap = true` について

`vim.keymap.set` はデフォルトで `noremap = true` として動作するため、本設定では明示的に指定していません。マッピングの再帰展開を防ぎ、意図しない連鎖を起こしません。

### コマンド文字列 vs 関数コールバック

キーマップの割り当てには2つのパターンがあります:

```lua
-- 1. コマンド文字列: Vimコマンドをそのまま実行
vim.keymap.set("n", "<leader>ma", "<Cmd>make!<CR>", { silent = true })

-- 2. 関数コールバック: Luaでロジックを書ける
vim.keymap.set("n", "<leader>tf", function()
    go_test_runner("function")
end)
```

DAP のステップ実行や Go test runner のように、条件分岐やエラーハンドリングが必要なものは関数コールバックを使っています。

### `<cword>` / `<cfile>` 展開

Telescope 系のマップや `gx` で使われているパターンです:

- `vim.fn.expand("<cword>")` — カーソル下の単語を取得
- `vim.fn.expand("<cfile>")` — カーソル下のファイル名/URLを取得

`<leader>ff` を押すと、カーソル下の単語を検索語として Telescope が開きます。

### DAP UI のライフサイクル

デバッグ開始・終了に連動して DAP UI が自動で開閉します。この仕組みは `plugins.lua` 内の listener で制御しています:

```lua
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
```

---

## 設定ファイルの参照
各プラグインの詳細設定や追加のキーマップについては、以下のファイルを確認してください。

*   `nvim/lua/plugins.lua`: プラグインのインストール定義
*   `nvim/lua/config/keymap.lua`: 汎用キーマップ（buffer, window, Telescope, Go test, Fugitive, gx）
*   `nvim/lua/config/lsp.lua`: 全LSP関連キーマップ（native, Saga, diagnostics）
*   `nvim/lua/config/dap.lua`: DAP adapter設定 + キーマップ
*   `nvim/lua/config/terminal.lua`: ターミナル toggle キーマップ
*   `nvim/lua/config/overseer.lua`: タスク実行キーマップ
