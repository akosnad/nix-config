{ config, ... }:
let
  flakeConfig = config;
in
{
  config.flake.modules.nixos.nix-cache-proxy = { config, ... }:
    {
      # TODO: this is a hack to force local hosts to use the LAN nix cache
      # this is a workaround to allow tailscale and the LAN nix cache to work together
      networking.hosts = {
        ${flakeConfig.flake.devices.hyperion.ip} = [ "nix.fzt.one" "hyperion" "hyperion.home.arpa" ];
      };

      # need to set tailscale flag: --accept-dns=false
      # to have resolved work
      networking.nameservers = [ "100.100.100.100" flakeConfig.flake.devices.gaia.ip ];
      services.resolved = {
        enable = true;
        domains = [ "tailnet.fzt.one" config.networking.domain ];
      };
    };
}
