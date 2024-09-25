args: {
  home-assistant-custom-components = import ./home-assistant-custom-components args;
  home-assistant-custom-lovelace-modules = import ./home-assistant-custom-lovelace-modules args;
  home-assistant-custom-themes = import ./home-assistant-custom-themes args;
  nodePackages = import ./nodePackages args;
  vim-plugins = import ./vim-plugins args;

  librespot-auth = import ./librespot-auth args;
  dynisland = import ./dynisland args;
  dynisland-modules = import ./dynisland-modules args;
}
