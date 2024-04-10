{ lib, ... }:
{
  virtualisation.docker = {
    enable = true;
  };

  systemd.services.docker = {
    enable = true;
    # Only start docker when the socket is first accessed
    wantedBy = lib.mkForce [ ];
  };
}
