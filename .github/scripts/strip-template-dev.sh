#!/usr/bin/env bash
# テンプレート開発専用のファイル・記述を作業ツリーから除去する。
#   1. .templateignore にマッチする追跡ファイルを削除
#   2. 残ったファイル中の `template-dev:begin` 〜 `template-dev:end` の
#      行範囲を（マーカー行を含めて）削除
#      マーカー行はコメント記号と空白以外を含まない行とし、
#      コメント記法は問わない。例:
#        <!-- template-dev:begin -->
#        テンプレート開発時だけ必要な記述
#        <!-- template-dev:end -->
#      begin/end の対応が取れていない場合はエラーで終了する。
# 作業ツリーを直接書き換えるため、ローカルで試すときは
# git worktree 等の使い捨ての作業ツリーで実行すること。
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

readonly IGNORE_FILE=.templateignore
if [[ ! -f ${IGNORE_FILE} ]]; then
  echo "error: ${IGNORE_FILE} が見つかりません" >&2
  exit 1
fi

# マーカー行の判定。本文中でマーカー名に言及しても誤検出しないよう、
# コメント記号と空白以外を含まない行に限定する
export LC_ALL=C
readonly BEGIN_RE='^[[:space:][:punct:]]*template-dev:begin[[:space:][:punct:]]*$'
readonly END_RE='^[[:space:][:punct:]]*template-dev:end[[:space:][:punct:]]*$'

# 1. ファイル単位の除去（read-tree 直後は index と HEAD が異なるため --force が必要）
git ls-files -z --cached --ignored --exclude-from="${IGNORE_FILE}" |
  xargs -0 --no-run-if-empty git rm --quiet --force --

# 2. ファイル内の開発専用ブロックの除去
status=0
while IFS= read -r -d '' file; do
  if ! awk -v b="${BEGIN_RE}" -v e="${END_RE}" '
    $0 ~ b { if (skip) exit 1; skip = 1; next }
    $0 ~ e { if (!skip) exit 1; skip = 0; after = 1; next }
    skip { next }
    # ブロックの前後が空行だった場合、空行が二重にならないよう1行にまとめる
    after { after = 0; if ($0 == "" && last == "") next }
    { print; last = $0 }
    END { if (skip) exit 1 }
  ' "${file}" >"${file}.tmp"; then
    rm -f "${file}.tmp"
    echo "error: ${file} の template-dev マーカーの対応が取れていません" >&2
    status=1
    continue
  fi
  # パーミッションを保つため mv ではなく上書きする
  cat "${file}.tmp" >"${file}"
  rm -f "${file}.tmp"
  echo "stripped: ${file}"
done < <(git grep -lz 'template-dev:begin' || true)

exit "${status}"
