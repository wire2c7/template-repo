#!/usr/bin/env bash
# 配布物（release → main のPRで main に取り込まれる内容）を生成する。
# 使い方: preview-template.sh [--check] [<出力先>]
#   作業ツリーの追跡ファイル（未コミットの変更を含む。未追跡ファイルは含まない）を
#   対象に、テンプレート開発専用のものを除去した内容を <出力先> に展開する。
#   出力先は存在しないか空のディレクトリ。省略時は一時ディレクトリを作成する。
#   --check を付けると、生成した配布物で nix flake check と prek を実行する。
set -euo pipefail

check=false
if [[ ${1:-} == --check ]]; then
  check=true
  shift
fi

repo=$(git rev-parse --show-toplevel)
out=${1:-$(mktemp -d)}
if [[ -e ${out} && -n $(ls -A "${out}") ]]; then
  echo "error: ${out} は空ではありません" >&2
  exit 1
fi
mkdir -p "${out}"

# 未コミットの変更を含むツリー（変更がなければ HEAD）を展開する
ref=$(git -C "${repo}" stash create)
git -C "${repo}" archive "${ref:-HEAD}" | tar -x -C "${out}"

cd "${out}"
git init --quiet
git add --all
"${repo}/.github/scripts/strip-template-dev.sh" >/dev/null
git add --all

echo "配布物: ${out}"
if git -C "${repo}" rev-parse --verify --quiet origin/main >/dev/null; then
  git fetch --quiet "${repo}" refs/remotes/origin/main
  echo "origin/main との差分:"
  git diff --cached --stat FETCH_HEAD
fi

if [[ ${check} == true ]]; then
  nix flake check
  nix develop --command prek run --all-files
fi
