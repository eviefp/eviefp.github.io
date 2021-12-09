let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  gis = import sources.gitignore { inherit (pkgs) lib; };
in
  pkgs.haskell.packages.ghc8107.callCabal2nix "eviefp-blog" (gis.gitignoreSource ./.) {}
