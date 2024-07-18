{
  imports = [
    ./lan.nix
    ./wan.nix
    ./wifi-ap.nix
  ];

  networking = {
    hostName = "gaia";
    networkmanager.enable = false;
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "br-lan" ];
    };
  };
}
