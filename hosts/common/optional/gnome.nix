{ pkgs, ... }:
{
  services = {
    xserver = {
      enable = true;
      desktopManager.gnome = {
        enable = true;
      };
      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
    };
  };

  services.avahi.enable = false;
  services.dbus.packages = [ pkgs.gcr ];

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gedit
  ]) ++ (with pkgs.gnome; [
    cheese
    gnome-music
    epiphany
    geary
    evince
    gnome-characters
    totem
    tali
    iagno
    hitori
    atomix
  ]);

  environment.systemPackages = [
    pkgs.gnome3.gnome-tweaks
  ];
}
