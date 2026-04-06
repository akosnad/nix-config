{
  config.flake.devices = {
    gaia = {
      info = "Raspberry Pi 4B";
      ip = "10.0.0.1";
    };
    zeus = {
      info = "Core i7 2600, 16GB RAM";
      hidden = true;
      mac = "FA:49:89:96:57:D1";
      ip = "10.0.0.2";
    };

    hyperion = {
      info = "Core i7 4790S, 32GB RAM";
      mac = "74:D0:2B:90:C3:BC";
      ip = "10.0.0.3";
      extraHostnames = [
        "frigate"
        "media"
        "music"
        "jellyseerr"
        "nix.fzt.one"
      ];
      forwardedPorts = [
        # qbittorrent
        15577

        # SIP
        { proto = "udp"; dest = 5060; }
        { proto = "udp"; dest = 5065; source = 5065; }
      ];
    };
  };
}
