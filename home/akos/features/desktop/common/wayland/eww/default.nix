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

  eww-config-dir = pkgs.stdenvNoCC.mkDerivation {
    name = "eww-config";
    srcs = [ eww_config style ];
    sourceRoot = ".";
    buildInputs = [ pkgs.coreutils ];
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      for file in $srcs; do
        # remove preceding store hash from file names
        name=$(basename $file | sed 's/^[a-z0-9]\{32\}-//')
        ln -s $file $out/$name
      done
    '';
  };

  eww_pkg = config.programs.eww.package;
in

{
  programs.eww = {
    enable = true;
    configDir = eww-config-dir;
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
