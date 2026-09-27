# テンプレート開発ガイド

このリポジトリ自体（テンプレート）を開発するためのドキュメントです。
このファイルは `main` には取り込まれず、テンプレート利用者には配布されません。

## ブランチ運用

GitHubのTemplate Repositoryは既定ブランチ（`main`）の内容をコピーするため、`main` は常に「テンプレートとしてそのまま使える状態」に保ちます。

```mermaid
flowchart LR
  feature["作業ブランチ"] -. "PR（任意）" .-> develop
  develop["develop<br/>開発作業"] -- "PR" --> release["release<br/>リリース候補"]
  release -- "push で<br/>ワークフロー起動" --> rtm["release-to-main<br/>開発専用ファイルを除去"]
  rtm -- "自動作成された PR" --> main["main<br/>配布される内容"]
  main -- "Use this template" --> repo(["新規リポジトリ"])
```

| ブランチ | 役割 | 更新方法 |
| --- | --- | --- |
| `develop` | テンプレートの開発作業 | 直接コミット、または作業ブランチからPR |
| `release` | リリース候補（開発用ドキュメントを含む） | `develop` からPRでマージ |
| `main` | 配布用（開発用ドキュメントを含まない） | `release-to-main` ブランチからのPRでのみ更新 |

## release → main の自動化

`release` への push で `.github/workflows/release-to-main.yaml` が `main` へのPRを作成・更新します。処理内容はワークフローを参照してください。

`main` を起点にツリーを `release` の内容で丸ごと置き換えてから除去するため、PRの差分は「現在の `main`」と「新しい配布内容」の差になります。
`main` の履歴やマージ方法（merge / squash）に関係なくコンフリクトしません。

## 配布しないものの指定

### ファイル単位: `.templateignore`

gitignore と同じ書式でパスを列挙します。

### ファイル内の一部: `template-dev` マーカー

ファイル内の開発専用の記述はマーカーで囲みます。書式は `.github/scripts/strip-template-dev.sh` 冒頭のコメントを参照してください。

### 配布物をローカルで確認する

`.github/scripts/preview-template.sh` で配布物を生成・検証できます。使い方はスクリプト冒頭のコメントを参照してください。

## 依存の更新

このリポジトリでは Renovate を使いません。Renovate は既定ブランチ（`main`）にしか更新PRを作れず、`develop` → `release` → `main` の運用と両立しないためです。
派生リポジトリは作成直後から Renovate で更新されるため、このリポジトリの依存が多少古くても影響は小さく、必要に応じて `develop` で手動で更新します。

- `flake.lock`: `nix flake update`
- GitHub Actions の参照（`wire2c7/workflows` を含む）: コミットハッシュとバージョンのコメントを更新する。テンプレート開発専用のワークフローも対象
- `.github/renovate.json5` の共有設定のバージョン

## リポジトリの初期設定

- [ ] Settings → General → **Template repository** を有効にする
- [ ] 既定ブランチが `main` であることを確認する
- [ ] `develop` と `release` ブランチを作成する
- [ ] Fine-grained PAT を発行し、Secrets の `RELEASE_PR_TOKEN` に登録する
  - 対象はこのリポジトリのみとし、Contents・Pull requests・Workflows の Read and write 権限を付与する
  - `GITHUB_TOKEN` ではワークフローファイルを含むコミットを push できず、作成したPRで CI も起動しないため必須
  - 有効期限が切れると `Release to main` ワークフローが失敗するため、期限前に更新する
- [ ] Renovate GitHub App を全リポジトリ対象でインストールしている場合は、このリポジトリを対象から除外する
- [ ] Settings → Rules → Rulesets で `main`・`release` それぞれにルールセットを作成する
  - PR必須（承認数0）、ステータスチェック `ci / check`（GitHub Actions）必須、force push・削除の禁止。迂回（bypass）は設定しない
  - `release` のマージ方法は Merge commit のみにする（squash すると `develop` と履歴が分岐し、以降のPRでコンフリクトするため）
