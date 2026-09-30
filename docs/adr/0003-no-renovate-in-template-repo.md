# 0003. このリポジトリでは Renovate を使わない

- ステータス：Accepted
- 日付：2026-09-27
- 関連 Issue：なし

## コンテキスト

このリポジトリは `develop` → `release` → `main` の順に配布物を作り、`main` は `release-to-main` ブランチからの PR でのみ更新する（[0002](0002-branch-strategy.md)）。

Renovate は設定を常に既定ブランチ（`main`）から読む。`main` の Renovate の設定は配布物の一部であり、テンプレートから作成したリポジトリ向けのものである。

## 検討した選択肢

- `main` の設定のまま Renovate を動かす：更新 PR が `main` に向き、`develop` → `release` → `main` の流れを迂回する
- `main` の設定で `baseBranchPatterns` に `develop` を指定する：設定が配布先にもコピーされ、`develop` の無いリポジトリに持ち込まれる。`template-dev` マーカーで除くと `main` から消え、Renovate が読めなくなる
- Renovate を使わず、`develop` で手動で更新する

## 決定

このリポジトリでは Renovate を使わず、依存は `develop` で手動で更新する。

配布先は作成直後から Renovate で更新されるため、このリポジトリの依存が多少古くても影響は小さい。

## 結果

- Renovate を全リポジトリ対象でインストールしている場合、このリポジトリを対象から除外する必要がある
- 依存の更新を忘れやすくなる。更新する対象と手順は `TEMPLATE_DEVELOPMENT.md` に置く
