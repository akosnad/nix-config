{ lib, ... }:
{
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ./builder-common.pub
    ];
  };

  services.openssh.settings = {
    PermitRootLogin = lib.mkForce "without-password";
  };
}
