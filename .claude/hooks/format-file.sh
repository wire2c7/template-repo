#!/usr/bin/env bash
# PostToolUse(Edit|Write)フック: 編集したファイルを treefmt で整形する。
# lint で失敗した場合は、その出力を Claude に返して修正させる。
set -euo pipefail

# use-devshell.sh は単体で lint されるため、ここでは追わない
# shellcheck disable=SC1091
source "${BASH_SOURCE[0]%/*}/use-devshell.sh" jq treefmt

file_path=$(jq -r '.tool_input.file_path // empty')

# リポジトリ外のファイルは対象外
[[ ${file_path} == "${CLAUDE_PROJECT_DIR}"/* && -f ${file_path} ]] || exit 0

if ! output=$(treefmt --quiet "${file_path}" 2>&1); then
  jq -n --arg output "${output}" '{
    decision: "block",
    reason: ("treefmt が失敗した。次の出力を見て修正すること。\n" + $output)
  }'
fi
