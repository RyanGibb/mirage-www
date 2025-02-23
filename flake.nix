{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    hillingar.url = "github:RyanGibb/hillingar";

    # use different repositories to those pinned in hillingar
    hillingar.inputs.opam-repository.follows = "opam-repository";
    hillingar.inputs.opam-overlays.follows = "opam-overlays";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    opam-overlays = {
      url = "github:dune-universe/opam-overlays";
      flake = false;
    };

    # make hillingar's nixpkgs follow this flake
    # useful if pinning nixos system nixpkgs with
    #   `nix.registry.nixpkgs.flake = nixpkgs;`
    hillingar.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, hillingar, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in {
        packages = let
          mirage-nix = (hillingar.lib.${system});
          inherit (mirage-nix) mkUnikernelPackages;
        in
          mkUnikernelPackages {
            unikernelName = "www";
            mirageDir = "mirage";
            # depexts for ocaml-gmp
            depexts = with pkgs; [ opam gnum4 ];
            # isn't picked up by `opam admin list`
            monorepoQuery = { gmp = "*"; };
          } self;

        defaultPackage = self.packages.${system}.unix;
      }
    );
}
