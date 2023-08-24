# plutus-flake-test
This repo is a test to showcase how "easy" it can be to use flakes to build some project using PlutusTx.

# The structure
The repository contains two haskall packages, `hello` and `world`. Besides hackage, this project also has CHaP in scope (see the cabal project file).

Building an output of the flake can be done via
```bash
nix build .#hello:exe:hello
```
or
```bash
nix build .#world:exe:world
```
which will output the binary in the result folder.

To directly run the executable you can use
```bash
nix run .#hello:exe:hello
```
Use
```bash
nix develop
```
to enter a shell with cabal hlint and the haskell language server.