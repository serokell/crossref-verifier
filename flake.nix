# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

{
  description =
    "A tool for verifying local and external references in repository documentation";

  edition = 201909;

  inputs.haskell-nix = {
    type = "github";
    # Replace with upstream once #567 is merged
    owner = "serokell";
    repo = "haskell.nix";
    ref = "flake";
  };

  outputs = { self, haskell-nix }:
    let
      # Perhaps we should provide a more convinient way to do this?
      lib = import "${haskell-nix.sources.nixpkgs-default}/lib";
      inherit (lib) genAttrs;

      # Unfortunately, this is the only way to pass `nix flake check`
      # Because of IFD, evaluating packages for systems other than current is not possible
      # We should think of some way to fix that (I'm not sure if there is one)
      systems = [ "x86_64-linux" ];

      mkProject = system: static: import ./xrefcheck.nix { nixpkgs = haskell-nix.legacyPackages.${system}; inherit static; };
      mkExes = system: (mkProject system false).components.exes;
      mkStatic = system: { xrefcheck-static = (mkProject system true).components.exes.xrefcheck; };
      mkTests = system: (mkProject system false).components.tests;
    in {
      packages = genAttrs systems (s: mkStatic s // mkExes s);
      defaultPackage = builtins.mapAttrs (n: v: v.xrefcheck) self.packages;
      checks = genAttrs systems mkTests;
    };
}
