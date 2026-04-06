{
  config.flake.modules.nixos.iscsi-initiator =
    { config, ... }:
    {
      services.openiscsi = {
        enable = true;
        name = "iqn.2003-01.${config.networking.hostName}.${config.networking.domain}";
      };
    };
}
