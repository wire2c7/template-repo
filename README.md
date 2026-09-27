# template-repo

<!-- template-dev:begin -->
> [!NOTE]
> テンプレート自体の開発方法は [TEMPLATE_DEVELOPMENT.md](TEMPLATE_DEVELOPMENT.md) を参照してください。
<!-- template-dev:end -->

新規リポジトリ用のGitHubテンプレートです。次のものが最初からセットアップされた状態で開発を始められます。

- **Nix devShell**（flake-parts）による再現可能な開発環境
- **treefmt** によるフォーマッタの集約（`nix fmt`）
- **prek** によるGitフック（ファイル検査、フォーマット、シークレット検出、コミットメッセージ検証）
- **GitHub Actions** によるCI（ローカルのフックと同じチェック）
- **Renovate** による依存関係（`flake.lock`、GitHub Actions）の自動更新
- **AGENTS.md** によるAIコーディングエージェント向けの指示

## 含まれるもの

| ファイル | 役割 |
| --- | --- |
| `flake.nix` / `flake.lock` | devShell・treefmt・`nix flake check` の定義 |
| `.envrc.example` | direnv 用（devShell の読み込みと `.env` の読み込み） |
| `.env.example` | ローカル用環境変数の雛形 |
| `.pre-commit-config.yaml` | prek のフック定義 |
| `.commitlintrc.yaml` | Conventional Commits の検証ルール（日本語の subject に対応） |
| `.editorconfig` | エディタ共通の書式設定 |
| `.github/workflows/ci.yaml` | CI（flake check、prek、betterleaks、commitlint） |
| `.github/renovate.json5` | Renovate の設定 |
| `.github/pull_request_template.md` / `.github/ISSUE_TEMPLATE/` | PR・Issue のテンプレート |
| `AGENTS.md` | AIエージェント向けのプロジェクト指示（Claude Code もこれを読む） |

## 前提

- [Nix](https://nixos.org/)（flakes 有効）
- [direnv](https://direnv.net/) と [nix-direnv](https://github.com/nix-community/nix-direnv)（任意・推奨）

## 使い方

1. GitHubで **Use this template** から新規リポジトリを作成し、clone する
2. 開発環境に入る

   ```sh
   # direnv を使う場合
   cp .envrc.example .envrc
   cp .env.example .env   # 環境変数が必要な場合
   direnv allow

   # direnv を使わない場合
   nix develop
   ```

   devShell に入ると prek の Gitフック（pre-commit / commit-msg）が自動でインストールされます。

3. 下のチェックリストに沿ってプロジェクト固有の設定をする

## テンプレートから作成した後のチェックリスト

- [ ] `flake.nix` の `description` を変更する
- [ ] `flake.nix` の `devShells.default.packages` に言語ツールチェーンを追加する
- [ ] `flake.nix` の `treefmt.programs` に使用言語のフォーマッタを追加する
- [ ] `.gitignore` に言語固有の除外パターンを追加する
- [ ] `AGENTS.md` の TODO（プロジェクト概要、ビルド・テストコマンド）を埋める
- [ ] CI にビルド・テストのステップを追加する
- [ ] リポジトリに [Renovate GitHub App](https://github.com/apps/renovate) をインストールする
- [ ] ブランチ保護で CI の `check` ジョブを必須にする
- [ ] この README をプロジェクト用に書き換える

## よく使うコマンド

```sh
nix fmt                  # フォーマット
nix flake check          # フォーマット検査など flake のチェック
prek run --all-files     # 全ファイルに Gitフックを実行
nix flake update         # 依存の更新（通常は Renovate に任せる）
```
