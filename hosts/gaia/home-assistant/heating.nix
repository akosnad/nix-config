{ pkgs, ... }:
{
  services.home-assistant = {
    customComponents = with pkgs.home-assistant-custom-components; [
      ariston-net
    ];
    config.ariston = {
      username = "!secret ariston_username";
      password = "!secret ariston_password";
    };
  };
}
