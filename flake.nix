{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/staging";
    jovian = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-emacs = {
      url = "github:nix-giant/nix-darwin-emacs/476ddf2a5d67188ef6f24e181a70b93da8da6828"; # unstable broken since 96b94326e010361d45802580f1c02ba5518db424
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "git+https://github.com/chaotic-cx/nyx.git?ref=nyxpkgs-unstable";
    rosetta-spice.url = "github:zhaofengli/rosetta-spice";
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
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
                  inputs.jovian.overlays.default
                  inputs.chaotic.overlays.default
                  inputs.emacs-overlay.overlays.package
                ]
                ++ lib.optionals (system == "aarch64-darwin") [
                  inputs.darwin-emacs.overlays.default
                ]
              );
            };
            lib = inputs.nixpkgs.lib;
            epkgs = pkgs.emacsPackagesFor pkgs.emacs-unstable;
          in
          {
            packages = lib.mkMerge [
              (lib.mkIf (pkgs.stdenv.isDarwin) {
                inherit (pkgs) emacs-unstable emacs-30;
                emacs-with-pack = epkgs.emacsWithPackages [
                  epkgs.nix-mode
                  epkgs.magit
                  epkgs.agda2-mode
                ];
                inherit (pkgs)
                  remmina
                  librewolf
                  thunderbird-esr
                  telegram-desktop
                  materialgram
                  ;
              })
              {
                inherit (pkgs) musescore;
                inherit (pkgs) sbcl;
                inherit (pkgs.emacsPackages) magit nix-mode agda2-mode;
              }
              (lib.mkIf (pkgs.stdenv.isLinux) {
                inherit (pkgs) totem gnome-session;
              })
            ];
          };
      }
    );
}
