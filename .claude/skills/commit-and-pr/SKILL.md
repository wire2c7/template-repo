---
name: commit-and-pr
description: Splits working-tree changes into logical commits and writes commit messages and pull requests that follow this repository's conventions. Use when the user asks to commit changes or open a pull request (e.g. "コミットして", "PRを作って", "変更をまとめて").
---

# コミット・PR の作成

作業ツリーの変更を論理的な単位のコミットに分け、必要なら PR を作る。規約そのものは `AGENTS.md` の「コミット・PR」を参照する。

## 手順

1. **変更を確認する**。`git status` と `git diff`（ステージ済みは `git diff --cached`）で全体を把握する。依頼と無関係な変更が混ざっていれば、コミットに含めるか確認する。

2. **コミットの単位を決める**。1コミットに1つの論理変更だけを入れる。迷ったら「この変更だけを revert して意味が通るか」で判断する。
   - `flake.nix` への依存パッケージの追加は、それを使う設定変更・ドキュメント更新と別コミットにする
   - 同じファイルに複数の論理変更がある場合は、`git add -p` を使わず、編集を分けてから順にコミットする（対話的なコマンドは使えないため）

3. **コミット前の確認をする**。
   - 設計判断を含む場合は `docs/adr/` に ADR があるか確認する（無ければ追加を提案する）
   - ドキュメントが実装と食い違っていないか確認する（`.claude/rules/docs.md`）
   <!-- template-dev:begin -->
   - 配布物に影響する変更なら `preview-template` スキルで検証する
   <!-- template-dev:end -->

4. **コミットする**。メッセージは `.commitlintrc.yaml` の規則に従い、件名は変更の目的が分かるように書く。フックが失敗したら原因を修正して再度コミットする（`--no-verify` は使わない）。

5. **PR を作る**（依頼された場合のみ）。push もユーザーの依頼があるときだけ行う。
   - タイトルは Conventional Commits の形式にする。コミットが1つならその件名を使う
   - 本文は `.github/pull_request_template.md` の見出しをすべて残して埋める。該当しない項目は「なし」と書く
   - チェックリストは実際に確認した項目だけチェックする
