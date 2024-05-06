{ pkgs, config, ... }:
{
  programs.eww = {
    enable = true;
    configDir =
      let

        helpers = import ./helpers.nix { inherit pkgs; };
        widgets = import ./widgets { inherit pkgs; };
        topbar = import ./topbar.nix { inherit pkgs; };

        style = import ./style.nix { inherit pkgs; scheme = config.colorscheme; };

        eww_config = pkgs.writeText "eww.yuck" /* yuck */ ''
          (include "${helpers}")
          (include "${widgets}")
          (include "${topbar}")
        '';

      in
      pkgs.stdenv.mkDerivation {
        name = "eww-config";
        builder = pkgs.writeScript "eww-config-builder.sh" /* bash */ ''
          ${pkgs.coreutils}/bin/mkdir -p $out
          ${pkgs.coreutils}/bin/cp ${eww_config} $out/eww.yuck
          ${pkgs.coreutils}/bin/cp ${style} $out/eww.css
        '';
      };

    package = pkgs.inputs.eww.eww;
  };
}
