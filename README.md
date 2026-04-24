# Neovim 設定 README

このプロジェクトの Neovim 設定に含まれる主要なプラグインと、その使い方をまとめたガイドです。

## 概要

本設定では、開発効率を向上させるために以下の主要カテゴリのプラグインが導入されています。

### カテゴリ別プラグイン一覧

| カテゴリ | プラグイン名 | 概要 |
| :--- | :--- | :--- |
| **ファイラー** | `neo-tree.nvim` | ファイルツリーエクスプローラー。 |
| **Outline** | `aerial.nvim` | 関数・クラス構造のシンボル一覧表示。 |
| **検索** | `telescope.nvim` | ファイル検索、Grep、シンボル検索。 |
| **LSP管理** | `nvim-lspconfig`, `mason` | 言語サーバーの管理。 |
| **シンタックス** | `nvim-treesitter` | コード構造解析・ハイライト。 |
| **デバッグ** | `nvim-dap` | デバッガー。 |
| **AI統合** | `codecompanion.nvim` | AIチャット/インラインコード編集。 |
| **AI補完** | `minuet-ai.nvim` | AIによるコード自動補完。 |
| **UI強化** | `noice.nvim` | 通知やコマンドラインの視覚的強化。 |
| **Git** | `vim-fugitive` | Gitコマンド操作・Diff確認。 |
| **タスク実行** | `overseer.nvim` | タスクランナー。 |
| **補完UI** | `nvim-cmp` | 補完メニューの表示管理。 |
| **Markdown** | `markdown-preview.nvim` | ブラウザでのリアルタイムプレビュー。 |

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

### LSP / 診断 (Diagnostics)
行番号の横に表示される `W` (Warning) や `E` (Error) の詳細を確認する操作です。

*   **詳細をフロート表示**: `gl` (カーソル位置), `<leader>h` (行全体)
*   **次/前の診断へジャンプ**: `]d`, `[d`
*   **エラー一覧をQuickfixで表示**: `<leader>e`
*   **警告一覧をQuickfixで表示**: `<leader>w`
*   **LSP定義確認/参照**: `gp` (定義覗き見), `gr` (参照/定義ファインダー)
*   **リネーム / コードアクション**: `<leader>rn`, `<leader>ca`

### 検索 (Telescope)
*   **ファイル検索**: `<leader>ff` (カーソル下のワードで検索)
*   **Live Grep**: `<leader>fg` (カーソル下のワードで検索)
*   **バッファ検索**: `<leader>fb`
*   **ドキュメント内シンボル**: `<leader>fs`
*   **ワークスペース内シンボル**: `<leader>fS`
*   **LSP参照一覧**: `<leader>fr`

### AI アシスト (CodeCompanion)
*   **AI アクションメニュー**: `<leader>aa`
*   **AI チャット (Claude)**: `<leader>aic`
*   **AI チャット (Gemini API)**: `<leader>aig`
*   **AI チャット (Gemini Login)**: `<leader>ail`
*   **AI チャット (ChatGPT)**: `<leader>aix`
*   **AI インライン生成**: `<leader>an` (ノーマル/ビジュアルモード両対応)

### AI 補完 (Minuet AI)
*   **手動トリガー**: `<A-f>`
*   **補完採用**: `<A-y>`
*   **行採用**: `<A-l>`
*   **次/前の候補**: `<A-]>`, `<A-[>`
*   **破棄**: `<A-e>`

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

### タスク実行 (Overseer)
*   **make実行**: `<leader>m` (Quickfixで結果表示)
*   **タスク実行 (選択)**: `<leader>r`
*   **タスク一覧表示**: `<leader>R`
*   **実行中タスクの停止**: `<leader>k`

### デバッグ (DAP)
*   **実行/継続**: `<F5>`
*   **ブレークポイント切り替え**: `<F9>`
*   **ステップオーバー/イン/アウト**: `<F10>`, `<F11>`, `<F12>`
*   **REPL表示**: `<leader>dr`
*   **ペイン最大化/復元**: `<leader>du`
*   **デバッグ停止**: `<leader>dt`

### Git 操作 (Fugitive)
*   **Git Diff (Index)**: `<leader>gd` (`:Gvdiffsplit` - 垂直分割)
*   **Git Diff (HEAD)**: `<leader>gh` (`:Gvdiffsplit HEAD` - 垂直分割)

---

## 設定ファイルの参照
各プラグインの詳細設定や追加のキーマップについては、以下のファイルを確認してください。

*   `nvim/lua/plugins.lua`: プラグインのインストール定義
*   `nvim/lua/config/keymap.lua`: 全てのキーマッピング定義
