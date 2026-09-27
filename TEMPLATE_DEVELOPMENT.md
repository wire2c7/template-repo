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

`release` に push されると `.github/workflows/release-to-main.yaml` が次の処理をします。

1. `origin/main` から `release-to-main` ブランチを作り、ツリーを `release` の内容で丸ごと置き換える
2. `.github/scripts/strip-template-dev.sh` でテンプレート開発専用のものを除去する
3. 1コミットにまとめて force push し、`main` へのPRを作成（既にあれば更新）する

ツリーを丸ごと置き換えるため、PRの差分は「現在の `main`」と「新しい配布内容」の差になります。
`main` の履歴やマージ方法（merge / squash）に関係なくコンフリクトしません。

## 配布しないものの指定

### ファイル単位: `.templateignore`

gitignore と同じ書式でパスを列挙します。

### ファイル内の一部: `template-dev` マーカー

`template-dev:begin` を含む行から `template-dev:end` を含む行までが（マーカー行を含めて）削除されます。
コメント記法は問わないので、各言語のコメントで書けます。

```markdown
<!-- template-dev:begin -->
テンプレート開発時だけ必要な記述
<!-- template-dev:end -->
```

begin と end の数が合わない場合、スクリプトはエラーで終了します。

### 除去結果をローカルで確認する

スクリプトは作業ツリーを直接書き換えるため、worktree 上で実行します。

```sh
git worktree add --detach ../template-preview HEAD
cp .github/scripts/strip-template-dev.sh /tmp/
(cd ../template-preview && /tmp/strip-template-dev.sh && git status --short)
git worktree remove --force ../template-preview
```

## リポジトリの初期設定

- [ ] Settings → General → **Template repository** を有効にする
- [ ] 既定ブランチが `main` であることを確認する
- [ ] `develop` と `release` ブランチを作成する
- [ ] Settings → Actions → General → **Allow GitHub Actions to create and approve pull requests** を有効にする
- [ ] （推奨）PRを作成するトークンを Secrets の `RELEASE_PR_TOKEN` に登録する
  - `GITHUB_TOKEN` で作成したPRでは CI（`pull_request` イベント）が起動しないため
  - Fine-grained PAT で、このリポジトリに対する Contents と Pull requests の Read and write 権限を付与する
- [ ] Renovate GitHub App をインストールする（`develop` 向けにPRが作られる）
- [ ] ブランチ保護: `main` と `release` への直接 push を禁止し、CI の `check` を必須にする
