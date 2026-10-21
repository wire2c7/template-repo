# 0007. このリポジトリの依存は運用専用リポジトリの self-hosted Renovate で更新する

- ステータス：Accepted
- 日付：2026-10-21
- 関連 Issue：なし

## コンテキスト

[0003](0003-no-renovate-in-template-repo.md) では、Renovate が設定を既定ブランチ（`main`）から読むこと、
`main` の内容がそのまま配布物であることから、このリポジトリでは Renovate を使わず `develop` で手動更新する
と決めていた。

手動更新は更新忘れが起きやすい（0003 の「結果」で挙げていた懸念）。配布先リポジトリは Mend-hosted の
Renovate GitHub App で自動更新されており（`README.md` のチェックリスト参照）、このリポジトリだけ手動なのは
一貫性を欠く。

## 検討した選択肢

- 手動更新のまま運用を続ける：更新忘れが起きやすい状態が変わらない
- `main` の Renovate 設定で `baseBranchPatterns` に `develop` を指定する：0003 で検討済みで、設定が配布先にも
  コピーされてしまう問題が残る
- 配布先と同じ Mend-hosted App をこのリポジトリにインストールする：Mend-hosted App は設定を既定ブランチから
  読むため、`main` に設定を置く必要があり、0003 の問題がそのまま残る
- 別のリポジトリから self-hosted Renovate を実行し、全体設定（グローバル設定）で対象リポジトリと
  base branch を指定する：設定がこのリポジトリの外にあるため、`main`・配布先どちらにも影響しない

## 決定

運用専用リポジトリ [wire2c7/renovate-runner](https://github.com/wire2c7/renovate-runner)（private）から、
週次で self-hosted Renovate を実行する。

- 認証は GitHub App（`wire2c7-renovate-runner`）を使う。このリポジトリにのみインストールし、
  Checks・Commit statuses・Contents・Issues・Pull requests・Workflows を Read and write 権限で付与する
- 全体設定（`config.js`）で `repositories: ["wire2c7/template-repo"]`・`baseBranchPatterns: ["develop"]` を
  指定し、`develop` ブランチへの更新PRを作る
- `renovate-runner` 自身の依存（Actions の参照等）は、配布先と同じ Mend-hosted App に任せる

## 結果

- このリポジトリの依存更新も、配布先と同様に自動化される
- 運用専用リポジトリと GitHub App の分だけ管理対象が増える。GitHub App の private key には有効期限がない
  （PAT と異なり失効による障害は起きない）が、App 自体の削除・権限変更には別途気を付ける必要がある
- `TEMPLATE_DEVELOPMENT.md` の「依存の更新」は、このリポジトリで直接行う手順ではなく
  `renovate-runner` 側の設定・運用を参照する記述に変える
