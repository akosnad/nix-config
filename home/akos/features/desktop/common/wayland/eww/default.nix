{ pkgs, config, ... } @ args:
let

  helpers = import ./helpers.nix args;
  widgets = import ./widgets args;
  topbar = import ./topbar.nix args;
  style = import ./style.nix (args // { scheme = config.colorscheme; });

  eww_config = pkgs.writeText "eww.yuck" /* yuck */ ''
    (include "${helpers}")
    (include "${widgets}")
    (include "${topbar}")
  '';

  eww-config-dir = pkgs.stdenv.mkDerivation {
    name = "eww-config";
    builder = pkgs.writeScript "eww-config-builder.sh" /* bash */ ''
      ${pkgs.coreutils}/bin/mkdir -p $out
      ${pkgs.coreutils}/bin/cp ${eww_config} $out/eww.yuck
      ${pkgs.coreutils}/bin/cp ${style} $out/eww.scss
    '';
  };

  eww_pkg = pkgs.eww;
in

{
  programs.eww = {
    enable = true;
    configDir = eww-config-dir;
    package = eww_pkg;
  };

  xdg.configFile."eww" = {
    source = eww-config-dir;
    onChange = /* bash */ ''
      PIDS="$(${pkgs.procps}/bin/pidof eww)"

      if [ -n "$PIDS" ]; then
        ${pkgs.procps}/bin/kill $PIDS && ${eww_pkg}/bin/eww open topbar
      fi
    '';
  };
}
