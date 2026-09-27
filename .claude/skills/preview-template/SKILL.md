---
name: preview-template
description: Generates and verifies the distributed template (what release → main will contain, with template-development-only content stripped). Use after changing files that are distributed to repositories created from this template, before opening a develop → release PR, or when the user asks to check/preview the template output (e.g. "配布物を確認して", "テンプレートの出力を見せて").
---

# 配布物のプレビューと検証

テンプレート開発専用のものを除去した配布物を生成し、テンプレートから作成されたリポジトリとして正しく機能するかを確認する。

## 手順

1. 新規ファイルがあれば `git add` する（未追跡ファイルは配布物に含まれない）。

2. 配布物を生成して検証する。

   ```sh
   .github/scripts/preview-template.sh --check
   ```

3. 出力された差分と配布物の内容を確認する。
   - 差分に意図しないファイルの追加・削除がないか
   - テンプレート開発専用の内容（`develop`・`release` ブランチ、`TEMPLATE_DEVELOPMENT.md`、テンプレートリポジトリ自体への言及等）が残っていないか。残っていれば `.templateignore` への追加か `template-dev` マーカーで対処する
   - 特定のプロジェクト・言語・個人に依存する内容が紛れ込んでいないか
   - マーカーの除去によって文章や設定の前後がつながらなくなっていないか

4. 問題があれば修正し、手順 2 からやり直す。

5. 確認が終わったら出力先のディレクトリを削除する。
