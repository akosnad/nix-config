{
  config.flake.modules.nixos."hosts/athena" = {
    programs.wireshark.enable = true;

    home-manager.users.akos = { };
  };
}
