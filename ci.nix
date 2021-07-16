# SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

rec {
  sources = import ./nix/sources.nix;
  haskell-nix = import sources."haskell.nix" {
    sourcesOverride = { hackage = sources."hackage.nix"; stackage = sources."stackage.nix"; };
  };
  serokell-nix = import sources."serokell.nix";
  pkgs = import sources.nixpkgs (
    haskell-nix.nixpkgsArgs // {
      overlays =
        haskell-nix.nixpkgsArgs.overlays
        ++ [ serokell-nix.overlay ]; # contains trailing whitespace check
    }
  );

  project-src = pkgs.haskell-nix.haskellLib.cleanGit {
    name = "xrefcheck";
    src = ./.;
  };

  xrefcheck-lib-and-tests = (import ./xrefcheck.nix { linux = true; });
  xrefcheck-static = (import ./xrefcheck.nix { linux-static = true; }).components.exes.xrefcheck;
  xrefcheck-windows = (import ./xrefcheck.nix { windows = true; }).components.exes.xrefcheck;

  trailing-whitespace-check = pkgs.build.checkTrailingWhitespace project-src;

  # nixpkgs has an older version of stack2cabal which doesn't build
  # with new libraries, use a newer version
  packages.stack2cabal = (pkgs.haskellPackages.callHackageDirect {
    pkg = "stack2cabal";
    ver = "1.0.11";
    sha256 = "00vn1sjrsgagqhdzswh9jg0cgzdgwadnh02i2fcif9kr5h0khfw9";
  } { }).overrideAttrs (o: {
    src = pkgs.fetchFromGitHub {
      owner = "hasufell";
      repo = "stack2cabal";
      rev = "afa113beb77569ff21f03fade6ce39edc109598d";
      sha256 = "1zwg1xkqxn5b9mmqafg87rmgln47zsmpgdkly165xdzg38smhmng";
    };
    version = "1.0.12";
  });
}
