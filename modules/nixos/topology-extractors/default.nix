{ lib, ... }:
let
  extractors = {
    services = import ./services.nix;
    arion = import ./arion.nix;
  };
in
lib.mapAttrs' (k: v: lib.nameValuePair "topology-extractor-${k}" v) extractors
