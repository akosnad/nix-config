{ config, pkgs, ... }:
{
  imports = [
    ./global
    ./features/helix/full.nix
    ./features/shell/full.nix
    ./features/desktop/hyprland
    ./features/vscode.nix
    ./features/vscode-server.nix
    ./features/chromium.nix
    ./features/shell/azure.nix
    ./features/discord.nix
    ./features/darktable.nix
    ./features/onedrive.nix
    ./features/shell/iamb.nix
    ./features/kicad.nix
  ];

  specialisation.light.configuration.stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/equilibrium-gray-light.yaml";

  monitors =
    let
      primary =
        {
          name = "DP-2";
          model = "U28E850";
          width = 3840;
          height = 2160;
          scale = 1.5;
          x = 0;
          workspace = "1";
          primary = true;
          vrr = 1;
        };
      secondary =
        rec {
          name = "HDMI-A-1";
          model = "ASUS VN247";
          width = 1920;
          height = 1080;
          x = -width;
          workspace = "2";
        };
      aux =
        {
          name = "HDMI-A-2";
          model = "LF24T35";
          width = 1920;
          height = 1080;
          x = builtins.floor (primary.width / primary.scale);
          workspace = "3";
          vrr = 1;
        };
    in
    [
      primary
      secondary
      aux
      {
        name = "Unknown-1";
        enabled = false;
      }
    ];

  home.packages = with pkgs; [
    gimp3
    inkscape
  ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".local/share/Steam"
    ".local/share/lutris"
    "Games"
  ];
}
