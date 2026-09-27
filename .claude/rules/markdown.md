---
paths:
  - "**/*.md"
---

# Markdown 規約

`*.md` は [Google Markdown Style Guide](https://google.github.io/styleguide/docguide/style.html) に従う。

## 主な規約

- 見出しはATX形式（`#`）を使い、アンダーライン形式は使わない
- コードブロックはフェンス（\`\`\`）を使い、言語を指定する（インデント形式は使わない）
- 表は整った表形式データにのみ使い、それ以外はリスト・見出しで表現する
- 図は画像ではなく Mermaid で書く（GitHub 上で描画され、差分をレビューできるため）

## 自動チェック

- 末尾空白・末尾改行: prek の組み込みフック（`prek`）
