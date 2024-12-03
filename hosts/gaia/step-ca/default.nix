{ config, pkgs, ... }:
{
  services.step-ca = {
    enable = true;
    intermediatePasswordFile = config.sops.secrets.step-ca-password.path;
    address = "0.0.0.0";
    port = 4443;
    settings = builtins.fromJSON (builtins.readFile ./ca.json);
  };

  sops.secrets.step-ca-password = {
    sopsFile = ../secrets.yaml;
  };

  environment.systemPackages = with pkgs; [
    step-cli
  ];
}
