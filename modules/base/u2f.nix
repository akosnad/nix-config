{
  config.flake.modules.nixos.base = { config, ... }: {
    security.pam.u2f = {
      enable = true;
      control = "sufficient";
      settings = {
        debug = false;
        origin = "pam://akosnad-nixos-common";
        appid = "pam://akosnad-nixos-common";
        authfile = config.sops.secrets.u2f-mappings.path;
      };
    };

    sops.secrets.u2f-mappings = {
      mode = "444";
    };

    # security.pam.yubico = {
    #   enable = true;
    #   debug = false;
    #   id = "102521";
    #   mode = "client";
    #   control = "sufficient";
    # };
  };
}
