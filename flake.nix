{
  inputs = {
    nixpkgs.follows = "chaotic/nixpkgs";
    chaotic.url = "git+https://github.com/lonerOrz/nyx-loner.git";
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        imports = [
        ];
        flake = {
        };
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        perSystem =
          args@{
            system,
            pkgs,
            ...
          }:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = (
                [
                  inputs.chaotic.overlays.default
                ]
                ++ lib.optionals (system == "aarch64-darwin") [
                ]
              );
            };
            lib = inputs.nixpkgs.lib;
          in
          {
            packages = lib.mkMerge [
              (lib.mkIf (pkgs.stdenv.isDarwin) {
              })
              {
              }
              (lib.mkIf (system == "x86_64-linux") {
                inherit (pkgs.pkgsx86_64_v3) zotero localsend;
              })
            ];
          };
      }
    );
}
