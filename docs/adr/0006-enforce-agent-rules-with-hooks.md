# 0006. エージェント向けの規約を Claude Code の設定とフックで強制する

- ステータス：Accepted
- 日付：2026-10-02
- 関連 Issue：なし

## コンテキスト

`AGENTS.md` の禁止事項（シークレットを扱わない、`flake.lock` を手で編集しない、`--no-verify` でフックを回避しない）は文章で書いているだけで、エージェントが読み落とせば守られない。

また、整形の崩れはコミット時の pre-commit フックで初めて検出されるため、コミットが失敗してから直す手戻りが起きる。

## 検討した選択肢

- `AGENTS.md` に書くだけにする：仕組みが増えないが、守られる保証がない
- `permissions.deny` で禁止する：設定だけで済む。ただし例外を書けないため、`.env.*` を禁止すると雛形の `.env.example` も読めなくなる。コマンドの引数の位置も表現しにくい
- PreToolUse・PostToolUse フックで判定する：例外や引数の位置も判定できる。スクリプトの保守が必要になる

## 決定

単純なパス指定で済むものは `permissions.deny`、それ以外はフックで判定する。

- `flake.lock` の編集：`permissions.deny`（`Edit(./flake.lock)`）
- `.env`・`.env.*` の読み書き：`.env.example` を例外にするため PreToolUse フック
- `git` コマンドの `--no-verify`：PreToolUse フック
- 整形：編集したファイルに PostToolUse フックで `treefmt` を実行し、lint のエラーは Claude に返して修正させる

フックは Claude Code 本体の環境変数を引き継いで実行され、SessionStart フックで読み込んだ direnv の環境（`CLAUDE_ENV_FILE`）は Bash ツールにしか反映されない。そのため、`jq`・`treefmt` が `PATH` に無い場合は `direnv exec` で devShell の環境を読み込んで実行し直す。それでも無ければ何もしない。フックの失敗で作業そのものを止めないためである。

## 結果

- 禁止事項を破る操作は、理由とともに差し戻される
- 整形の崩れは編集した時点で直り、lint のエラーもその場で修正される
- 完全な防御ではない。Bash 経由のファイル読み取り（`cat .env` 等）や、`-n` などの短いオプションによるフックの回避は検出しない。誤検出が増えるため、判定は広げていない
- 逆に、コミットメッセージ等の引数に `--no-verify` という文字列を含む `git` コマンドは誤って止める
- direnv を使わずに devShell 外から Claude Code を起動した場合は、フックによる保護と整形は働かない
