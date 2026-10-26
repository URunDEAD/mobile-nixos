{ mobile-nixos
, fetchgit
, lib
, ...
}:

# Mainline-based SM7635 tree maintained by the Fairphone 6 community port.
mobile-nixos.kernel-builder {
  version = "7.2.0";
  configfile = ./config.aarch64;

  src = fetchgit {
    url = "https://forgejo.catcrafts.net/Catcrafts/milos-linux.git";
    rev = "63289f4411520a2acb38bd533437446d33fbce74";
    # TODO: fill in (nix-prefetch-git); left as a placeholder in this draft.
    hash = lib.fakeHash;
  };

  patches = [
  ];

  isModular = true;
  isCompressed = "gz";
}
