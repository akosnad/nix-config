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

  # even though we don't evaluate anything under the platform `x86_64-darwin`
  # (or at least I believe we don't), nixpkgs throws the eval warning about
  # this deprecated platform. we explicitly silence it for good.
  # reference: https://nixos.org/manual/nixpkgs/stable/release-notes#x86_64-darwin-26.05
  # TODO: remove after upgrade to 26.11
  allowDeprecatedX86_64Darwin = true;
}
