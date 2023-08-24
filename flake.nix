{
  description = "A very basic flake";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.CHaP = {
  url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
  flake = false;
  };
  inputs.iohkNix.url = "github:input-output-hk/iohk-nix";

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
      flake = pkgs.helloWorldProject.flake {
        # This adds support for `nix build .#js-unknown-ghcjs:hello:exe:hello`
        # crossPlatforms = p: [p.ghcjs];
      };
    in flake // {
      # Built by `nix build .`
      packages.hello = flake.packages."hello:exe:hello";
      # packages.world = flake.packages."world:exe:world";
    });
}