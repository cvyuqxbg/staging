{
  inputs = {
    #nixpkgs.follows = "chaotic/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "git+https://github.com/lonerOrz/nyx-loner.git";
    # bad for cache:
    chaotic.inputs.nixpkgs.follows = "nixpkgs";
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
            pkgs-cuda = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              config.cudaSupport = true;
              overlays = ([
                inputs.chaotic.overlays.default
              ]);
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
                v3ssss = (
                  pkgs.symlinkJoin {
                    name = "v3ssss";
                    # cache dependencies for those packages:
                    paths = with pkgs.pkgsx86_64_v3; [
                      systemd
                      tmux
                      nano
                      dbus
                      pipewire
                      openssh
                      nix
                      kdePackages.kdeconnect-kde
                    ];
                  }
                );
                v3sssscuda = (
                  pkgs-cuda.symlinkJoin {
                    name = "v3sssscuda";
                    # cache dependencies for those packages:
                    paths = with pkgs-cuda.pkgsx86_64_v3; [
                      systemd
                      tmux
                      nano
                      dbus
                      pipewire
                      openssh
                      nix
                      kdePackages.kdeconnect-kde
                    ];
                  }
                );
                inherit (pkgs.pkgsx86_64_v3) zotero localsend zulip gtk3;
              })
            ];
          };
      }
    );
}
