#!/usr/bin/env bash
# テンプレート開発専用のファイル・記述を作業ツリーから除去する。
#   1. .templateignore にマッチする追跡ファイルを削除
#   2. 残ったファイル中の `template-dev:begin` 〜 `template-dev:end` の行範囲を削除
# 作業ツリーを直接書き換えるため、ローカルで試すときは git worktree 等の使い捨ての作業ツリーで実行すること。
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ignore_file=.templateignore
if [[ ! -f $ignore_file ]]; then
  echo "error: $ignore_file が見つかりません" >&2
  exit 1
fi

# マーカー行: コメント記号と空白以外に何も含まない行（本文中でマーカー名に言及しても誤検出しない）
export LC_ALL=C
begin_re='^[[:space:][:punct:]]*template-dev:begin[[:space:][:punct:]]*$'
end_re='^[[:space:][:punct:]]*template-dev:end[[:space:][:punct:]]*$'

# 1. ファイル単位の除去（read-tree 直後は index と HEAD が異なるため --force が必要）
git ls-files -z --cached --ignored --exclude-from="$ignore_file" |
  xargs -0 --no-run-if-empty git rm --quiet --force --

# 2. ファイル内の開発専用ブロックの除去
status=0
while IFS= read -r -d '' file; do
  if ! awk -v b="$begin_re" -v e="$end_re" '
    $0 ~ b { if (skip) exit 1; skip = 1; next }
    $0 ~ e { if (!skip) exit 1; skip = 0; after = 1; next }
    skip { next }
    # ブロックの前後が空行だった場合、空行が二重にならないよう1行にまとめる
    after { after = 0; if ($0 == "" && last == "") next }
    { print; last = $0 }
    END { if (skip) exit 1 }
  ' "$file" >"$file.tmp"; then
    rm -f "$file.tmp"
    echo "error: $file の template-dev マーカーの対応が取れていません" >&2
    status=1
    continue
  fi
  cat "$file.tmp" >"$file" # パーミッションを保つため mv ではなく上書きする
  rm -f "$file.tmp"
  echo "stripped: $file"
done < <(git grep -lzE "template-dev:begin" || true)

exit "$status"
