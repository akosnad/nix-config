{ pkgs, lib, inputs, config, ... }:
let
  ipxeRootCA = pkgs.fetchurl {
    url = "http://ca.ipxe.org/ca.crt";
    hash = "sha256-DXVHxibSR53rA0Vf/EflY4VbuVZdjT00irctHun4fJY=";
  };
  trustCertChain = [ ipxeRootCA ../../../common/gaia-roots.pem ];

  # in nixpkgs targets are hardcoded to always include binaries for the host
  # platform. we don't want that here. we only want to build for the
  # following targets:
  ipxeTargets = {
    "bin-x86_64-efi/ipxe.efi" = "ipxe.efi";
    "bin/undionly.kpxe" = "undionly.kpxe";

  };

  pkgs_x86-64 = import inputs.nixpkgs { config = { }; overlays = [ ]; system = "x86_64-linux"; };

  ipxe = (pkgs_x86-64.ipxe.override {
    additionalOptions = [
      "CERT_CMD"
      "CONSOLE_CMD"
      "IMAGE_PNG"
      "POWEROFF_CMD"
      "REBOOT_CMD"

      "IMAGE_CRYPT_CMD"
      "IMAGE_TRUST_CMD"
      "DOWNLOAD_PROTO_HTTPS"
    ];
  }).overrideAttrs (_finalAttrs: prevAttrs: {
    makeFlags = prevAttrs.makeFlags ++ (
      let certs = builtins.concatStringsSep "," trustCertChain; in [
        # embed cert chain into binary
        "CERT=${certs}"
        # also trust the embedded certs
        "TRUST=${certs}"

        "DEBUG=tls"
      ]
    );

    # the rest is borrowed from nixpkgs, overriding the hardcoded default targets
    # with locally defined ipxeTargets
    buildFlags = lib.attrNames ipxeTargets;
    installPhase = ''
      runHook preInstall

      mkdir -p $out
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          from: to: if to == null then "cp -v ${from} $out" else "cp -v ${from} $out/${to}"
        ) ipxeTargets
      )}

      # Some PXE constellations especially with dnsmasq are looking for the file with .0 ending
      # let's provide it as a symlink to be compatible in this case.
      ln -s undionly.kpxe $out/undionly.kpxe.0

      runHook postInstall
    '';
  });

  tftp-root = pkgs.stdenvNoCC.mkDerivation {
    name = "dnsmasq-tftp-root";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -rv ${ipxe}/* $out/.
    '';
  };

  webrootUrl = "http://boot.home.arpa";
in
{
  services.dnsmasq = {
    settings = {
      enable-tftp = true;
      tftp-root = "${tftp-root}";

      # set tag 'ipxe' if request comes from iPXE (user class)
      dhcp-userclass = "set:ipxe,iPXE";
      dhcp-match = [ "set:efi-x86_64,option:client-arch,7" ];

      # disallow multicast and broadcast discovery, and ask to download boot file immediately
      # dhcp-option = [ "vendor:PXEClient,6,2b" ];

      dhcp-boot = [
        # if request comes from firmware, load iPXE over TFTP
        "tag:!ipxe,tag:efi-x86_64,ipxe.efi"
        "tag:!ipxe,tag:!efi-x86_64,undionly.kpxe"

        # if request comes from iPXE, direct it to bootstrap script
        "tag:ipxe,${webrootUrl}/boot.ipxe"
      ];

      dhcp-option = [
        # tell iPXE to trust the default cert chain
        "encap:175,93,http://ca.ipxe.org/auto"
      ];
    };
  };

  networking.hosts = {
    "::1" = [ "boot" "boot.${config.networking.domain}" ];
    "127.0.0.1" = [ "boot" "boot.${config.networking.domain}" ];
  };
  services.nginx.virtualHosts.boot = {
    forceSSL = false;
    onlySSL = false;
    enableACME = true;
    serverAliases = [ "boot.${config.networking.domain}" ];
    locations."/" = {
      root = "${tftp-root}";
      extraConfig = ''
        autoindex on;
      '';
    };
  };
}
