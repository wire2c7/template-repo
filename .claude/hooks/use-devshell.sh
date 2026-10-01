# shellcheck shell=bash
# フックスクリプトから source する。引数のコマンドが PATH に無ければ（devShell 外から
# Claude Code を起動した場合等）、direnv で devShell の環境を読み込んでスクリプトを
# 実行し直す。それでも見つからなければ、フックの失敗で作業を妨げないよう何もせずに終了する。
# direnv のログを抑止できないため、実行し直したスクリプトの stderr は捨てる。
# フックの結果は stdout の JSON で返すこと。

for cmd in "$@"; do
  command -v "${cmd}" >/dev/null && continue
  if [[ -z ${HOOK_DEVSHELL_LOADED:-} ]] && command -v direnv >/dev/null; then
    HOOK_DEVSHELL_LOADED=1 direnv exec "${CLAUDE_PROJECT_DIR}" "$0" 2>/dev/null || true
  fi
  exit 0
done
