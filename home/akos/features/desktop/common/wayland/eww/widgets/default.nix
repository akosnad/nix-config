{ pkgs, ... } @ args:
let
  widgets = [
    ./battery.nix
    ./cpu.nix
    ./disk.nix
    ./music.nix
    ./ram.nix
    ./volume.nix
    ./workspaces.nix
    ./window_title.nix
    ./keyboard_layout.nix
    ./time.nix
    ./securitykey.nix
  ];

  widget_imports = pkgs.lib.concatMapStrings (widget: /* yuck */ "(include \"${import widget args}\")\n") widgets;
in
pkgs.writeText "widgets.yuck" widget_imports
