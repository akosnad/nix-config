{
  imports = [
    ./lan.nix
    ./wan.nix
    ./wifi-ap.nix
  ];

  networking = {
    hostName = "gaia";
    useDHCP = false;
    networkmanager.enable = false;
    useNetworkd = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "br-lan" ];
    };
  };
}
