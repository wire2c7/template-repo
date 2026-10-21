{
  description = "template-repo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      systems,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = import systems;

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          # `nix fmt` / `nix flake check` (checks.treefmt) で使用
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              rumdl-check.enable = true;
              shellcheck.enable = true;
              shfmt = {
                enable = true;
                # フラグ付きで起動されると shfmt は .editorconfig を読まないため、明示的に揃える
                indent_size = 2;
              };
              zizmor.enable = true;
            };
            # direnv の DSL はシェルスクリプトとして解釈できないため除外
            settings.formatter.shellcheck.excludes = [ ".envrc*" ];
            settings.formatter.shfmt.excludes = [ ".envrc*" ];
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = [
              config.treefmt.build.wrapper
            ]
            ++ (with pkgs; [
              actionlint
              betterleaks
              commitlint
              jq
              ls-lint
              prek
              # 以下は、このリポジトリの現状のファイル構成に検査対象が無いため見送った汎用的な静的解析ツール。
              # 対象となるファイルを追加したら導入を検討する
              # semgrep # 多言語SAST。Nixは非対応、Bash/YAMLは実験的言語という位置付け
              # trivy # コンテナ・IaC・依存関係の脆弱性スキャン。対応形式（Dockerfile/Terraform/Kubernetes等）が無い
              # checkov # IaCのセキュリティ静的解析。対応形式が無い
            ]);

            shellHook = ''
              # ローカルではGitフックを冪等にインストール（フック種別は .pre-commit-config.yaml の default_install_hook_types）
              if [ -z "''${CI:-}" ] && git rev-parse --git-dir >/dev/null 2>&1; then
                prek install --quiet
              fi
            '';
          };
        };
    };
}
