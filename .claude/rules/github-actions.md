---
paths:
  - ".github/workflows/*.yml"
  - ".github/workflows/*.yaml"
---

# GitHub Actions規約

## 主な規約（ツールでは検出されない観点）

- `uses:` はコミットハッシュで固定し、コメントにバージョンを残す（`uses: owner/repo@<commit-hash> # vX.Y.Z`）。ハッシュの更新は Renovate に任せる
- `permissions` はワークフロー単位で最小限にし、書き込み権限が必要なジョブだけに付与する
- ツールは `nix develop --command` 経由で実行し、ローカルの devShell とバージョンを揃える（セットアップ用の Action でツールを別途インストールしない）
- zizmor の指摘を意図して受け入れる場合は、該当箇所の範囲内に `# zizmor: ignore[監査名] 理由` を書いて抑制する

## 自動チェック

- lint: `actionlint`（`prek`）
- セキュリティ監査: `zizmor`（`treefmt`。`persist-credentials: false` の要否・`${{ }}` のテンプレートインジェクション等を検出）
