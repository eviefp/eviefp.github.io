{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
  };

  outputs =
    { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux" # 64bit AMD/Intel x86
      ];

      forAllSystems = fn:
        nixpkgs.lib.genAttrs allSystems
          (system: fn { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      packages = forAllSystems
        ({ pkgs }:
          {
            default =
              pkgs.haskell.packages.ghc963.callCabal2nix "eviefp-blog" ./. { };
          });

      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          name = "blog-shell";
          nativeBuildInputs = [
            pkgs.zlib.dev
            pkgs.haskell.compiler.ghc963
            pkgs.haskell.packages.ghc963.cabal-install
            pkgs.haskell.packages.ghc963.cabal2nix
            pkgs.haskell.packages.ghc963.haskell-language-server
          ];
          buildInputs = [
            pkgs.httplz
          ];
        };
      });
    };
}
