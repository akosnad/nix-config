{ inputs, lib, ... }:
let
  name = "glide-browser";
  humanName = "Glide Browser";
  mkTarget = import "${inputs.stylix}/stylix/mk-target.nix" { inherit name humanName; };
in
lib.modules.importApply "${inputs.stylix}/modules/firefox/each-config.nix" { inherit mkTarget name humanName; }
