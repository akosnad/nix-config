{
  config.flake.modules.nixos."hosts/uranus" = {
    sops.secrets.restic-persist-password = {
      sopsFile = ./secrets.yaml;
    };
    sops.secrets.restic-postgres-password = {
      sopsFile = ./secrets.yaml;
    };
  };
}
