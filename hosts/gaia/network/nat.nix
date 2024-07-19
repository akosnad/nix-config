{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "br-lan" ];
    externalInterface = "bond-wan";
    forwardPorts = [
      # mqtt
      { destination = "10.20.0.4:8883"; proto = "tcp"; sourcePort = 32756; }

      # qbittorrent
      { destination = "10.20.0.4:15577"; proto = "tcp"; sourcePort = 15577; }
      { destination = "10.20.0.4:15577"; proto = "udp"; sourcePort = 15577; }
    ];
  };
}
