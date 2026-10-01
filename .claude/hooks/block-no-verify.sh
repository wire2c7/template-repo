#!/usr/bin/env bash
# PreToolUse(Bash)フック: --no-verify による Git フックの回避を禁止する（AGENTS.md）。
set -euo pipefail

# use-devshell.sh は単体で lint されるため、ここでは追わない
# shellcheck disable=SC1091
source "${BASH_SOURCE[0]%/*}/use-devshell.sh" jq

command=$(jq -r '.tool_input.command // empty')

[[ ${command} =~ (^|[^[:alnum:]_-])git[[:space:]].*--no-verify ]] || exit 0

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "--no-verify でフックを回避しない。フックが失敗した原因を修正すること（AGENTS.md）。"
  }
}'
