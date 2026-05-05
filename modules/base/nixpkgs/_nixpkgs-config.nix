{
  allowUnfree = true;
  allowUnfreePredicate = _: true;
  segger-jlink.acceptLicense = true;

  # this needs to be in a central location
  # as it is not a merged value in NixOS options
  permittedInsecurePackages = [
    # depends: modules/hosts/uranus/matrix/bridges.nix
    "olm-3.2.16"
    # depends: modules/vpn/just-for-fun.nix
    "mbedtls-2.28.10"
  ];
}
