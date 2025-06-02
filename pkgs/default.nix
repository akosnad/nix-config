args @ { pkgs, ... }: {
  home-assistant-custom-components = import ./home-assistant-custom-components args;
  home-assistant-custom-lovelace-modules = import ./home-assistant-custom-lovelace-modules args;
  home-assistant-custom-themes = import ./home-assistant-custom-themes args;
  nodePackages = import ./nodePackages args;
  vim-plugins = import ./vim-plugins args;

  librespot-auth = import ./librespot-auth args;

  quintom-snow-hyprcursor = import ./quintom-hyprcursor.nix (args // { variant = "snow"; });
  quintom-ink-hyprcursor = import ./quintom-hyprcursor.nix (args // { variant = "ink"; });

  # was removed upstream in 25.05; receives no updates
  # TODO: remove if re-inited upstream
  microsoft-edge = pkgs.callPackage (import ./microsoft-edge.nix) { };
}
