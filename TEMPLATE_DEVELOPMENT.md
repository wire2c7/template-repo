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

## リポジトリの初期設定

- [ ] Settings → General → **Template repository** を有効にする
- [ ] 既定ブランチが `main` であることを確認する
- [ ] `develop` と `release` ブランチを作成する
- [ ] Settings → Actions → General → **Allow GitHub Actions to create and approve pull requests** を有効にする
- [ ] （推奨）PRを作成するトークンを Secrets の `RELEASE_PR_TOKEN` に登録する
  - `GITHUB_TOKEN` で作成したPRでは CI（`pull_request` イベント）が起動しないため
  - Fine-grained PAT で、このリポジトリに対する Contents と Pull requests の Read and write 権限を付与する
- [ ] Renovate GitHub App をインストールする
- [ ] ブランチ保護: `main` と `release` への直接 push を禁止し、CI の `check` を必須にする
