{
  description = "A very basic flake for a plutusTx project";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };
    iohkNix.url = "github:input-output-hk/iohk-nix"; 
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, CHaP, iohkNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          # This overlay adds our project to pkgs
          helloWorldProject =
            final.haskell-nix.project' {
              src = ./.;
              inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = CHaP; };
              compiler-nix-name = "ghc928";
              # This is used by `nix develop .` to open a shell for use with
              # `cabal`, `hlint` and `haskell-language-server`
              shell.tools = {
                cabal = {};
                hlint = {};
                haskell-language-server = {};
              };
              # Non-Haskell shell tools go here
              shell.buildInputs = with pkgs; [
                nixpkgs-fmt
              ];
            };
        })
      # add overlay of the BLS/SECP primitives needed
      ] ++ [ iohkNix.overlays.crypto ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.helloWorldProject.flake {};
    in flake // rec {
      # Built by `nix build .
      packages.hello = flake.packages."hello:exe:hello";
      packages.world = flake.packages."world:exe:world";
      packages.default = packages.hello;
    });

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    accept-flake-config = true;
    allow-import-from-derivation = true;
  };
}