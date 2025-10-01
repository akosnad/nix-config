{ lib, ... }: {
  imports = [
    ../common/global
    ../common/users/akos
  ];

  environment.persistence."/persist".enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  wsl = {
    enable = true;
    defaultUser = "akos";
  };
  networking.hostName = "work-laptop";
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
