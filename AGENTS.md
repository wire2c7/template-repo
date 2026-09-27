# AGENTS.md

このファイルはAIコーディングエージェント（Claude Code、Codex等）向けのプロジェクト指示書です。
人間向けの説明は [README.md](README.md) を参照してください。

<!-- template-dev:begin -->
> [!IMPORTANT]
> このリポジトリはGitHubのテンプレートリポジトリそのものです。
> ブランチ運用・配布物の作り方は [TEMPLATE_DEVELOPMENT.md](TEMPLATE_DEVELOPMENT.md) に従ってください。
> 以降の記述はテンプレートから作成されたリポジトリにそのまま配布されるため、特定のプロジェクトに依存する内容を書かないこと。
> テンプレート開発時だけ必要な記述は `template-dev:begin` / `template-dev:end` マーカーで囲むこと。
<!-- template-dev:end -->

## プロジェクト概要

<!-- TODO: テンプレートから作成したら、このプロジェクトの目的・構成・主要な技術スタックを記述する -->

## 開発環境

- 開発ツールはすべてNix devShell（`flake.nix`）で管理する。グローバルインストール（`npm i -g`、`pip install --user`、`brew install` 等）はしない
- 新しいツールが必要な場合は `flake.nix` の `devShells.default.packages` に追加する
- コマンドは devShell 内で実行する。direnv が有効でない環境では `nix develop --command <cmd>` を使う
- 新規ファイルは `git add` するまで flake（`nix build` / `nix flake check` / `nix fmt` 等）から見えない点に注意
- ローカル用の環境変数は `.env` に書く（雛形は `.env.example`）。direnv 利用時は `.envrc` により自動で読み込まれる

## よく使うコマンド

| 目的 | コマンド |
| --- | --- |
| フォーマット | `treefmt`（devShell 外では `nix fmt`。どちらも同じ treefmt の設定で実行される） |
| 全チェック（CIと同等） | `nix flake check` と `prek run --all-files` |
| シークレット検査 | `betterleaks git --staged` |
| GitHub Actionsの検査 | `actionlint` |

<!-- TODO: ビルド・テスト・起動コマンドを追記する -->

## コーディング規約

- 基本的な書式は `.editorconfig` に従う
- フォーマッタ・リンタは treefmt（`flake.nix` の `treefmt.programs`）に集約する。言語を追加したら対応するものをそこへ追加する
- 変更は依頼された範囲に留め、無関係なリファクタリングを混ぜない

## コミット規約

- [Conventional Commits](https://www.conventionalcommits.org/ja/) に従う。ルールは `.commitlintrc.yaml` を参照（commitlint で検証される）
- subject・本文は日本語で書いてよい
- 1コミット1論理変更を基本とする
- PRは `.github/pull_request_template.md` の項目に沿って記述し、PRタイトルも Conventional Commits の形式にする

## Gitフック・CI

- Gitフックは prek（`.pre-commit-config.yaml`）で管理し、devShell に入ると自動でインストールされる
- `--no-verify` でフックを回避しない。フックが失敗したら原因を修正する
- CI（`.github/workflows/ci.yaml`）はローカルのフックと同じチェックを実行する。ローカルで通ればCIも通る状態を保つ
- GitHub Actionsはコミット SHA で固定する（Renovate が更新する）

## 禁止事項

- シークレット（APIキー、トークン、秘密鍵等）をコミットしない（`.env` はGit管理外）
- `flake.lock` を手で編集しない（`nix flake update` か Renovate に任せる）

## このファイルの保守

- このファイルと実態がずれた場合は、コードに合わせてこのファイルを更新する
