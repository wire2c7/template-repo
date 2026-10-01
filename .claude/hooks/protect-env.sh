#!/usr/bin/env bash
# PreToolUse(Read|Edit|Write|Grep)フック: シークレットを置く .env・.env.* を
# Claude のファイル操作から保護する（雛形の .env.example は除く）。
# permissions.deny では .env.example だけを例外にできないため、フックで判定する。
set -euo pipefail

# use-devshell.sh は単体で lint されるため、ここでは追わない
# shellcheck disable=SC1091
source "${BASH_SOURCE[0]%/*}/use-devshell.sh" jq

path=$(jq -r '.tool_input.file_path // .tool_input.path // empty')

case "${path##*/}" in
.env.example) exit 0 ;;
.env | .env.*) ;;
*) exit 0 ;;
esac

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ".env にはシークレットを置くため、読み書きしない。必要な変数名は .env.example を参照すること。"
  }
}'
