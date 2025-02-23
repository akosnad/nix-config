{ pkgs, lib, inputs, outputs, config, ... }:
let
  ipxeRootCA = pkgs.fetchurl {
    url = "http://ca.ipxe.org/ca.crt";
    hash = "sha256-DXVHxibSR53rA0Vf/EflY4VbuVZdjT00irctHun4fJY=";
  };
  trustCertChain = [ ipxeRootCA ../../../common/gaia-roots.pem ];

  pkgs-x86_64 = import inputs.nixpkgs { config = { }; overlays = [ ]; system = "x86_64-linux"; };

  mkIpxe = pkgs: targets: (pkgs.ipxe.override {
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

        # "DEBUG=tls"
      ]
    );

    # the rest is borrowed from nixpkgs, overriding the hardcoded default targets
    # with locally defined `targets`
    buildFlags = lib.attrNames targets;
    installPhase = ''
      runHook preInstall

      mkdir -p $out
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          from: to: if to == null then "cp -v ${from} $out" else "cp -v ${from} $out/${to}"
        ) targets
      )}

      # Some PXE constellations especially with dnsmasq are looking for the file with .0 ending
      # let's provide it as a symlink to be compatible in this case.
      ln -s undionly.kpxe $out/undionly.kpxe.0

      runHook postInstall
    '';
  });
  ipxeBuilds = {
    x86_64 = mkIpxe pkgs-x86_64 {
      "bin-x86_64-efi/ipxe.efi" = "ipxe.efi";
      "bin/undionly.kpxe" = "undionly.kpxe";
    };
    aarch64 = mkIpxe pkgs {
      "bin-arm64-efi/ipxe.efi" = "ipxe.efi";
    };
  };

  mkInstaller = system: lib.nixosSystem {
    modules = [ ((import ./installer) system) ];
    specialArgs = { inherit inputs outputs; };
  };
  installers = {
    x86_64 = mkInstaller "x86_64-linux";
    aarch64 = mkInstaller "aarch64-linux";
  };

  bootWebroot = "http://boot.${config.networking.domain}";

  tftp-root = pkgs.stdenvNoCC.mkDerivation {
    name = "dnsmasq-tftp-root";
    dontUnpack = true;
    buildPhase =
      let
        mkArchDir = arch: ''
          mkdir -p $out/${arch}/installer

          cp -rv --reflink=auto ${ipxeBuilds."${arch}"}/* $out/${arch}/.

          ln -vs ${installers."${arch}".config.system.build.kernel}/${installers."${arch}".config.system.boot.loader.kernelFile} $out/${arch}/installer/kernel
          ln -vs ${installers."${arch}".config.system.build.initialRamdisk}/initrd $out/${arch}/installer/initrd

          cat << EOF > $out/${arch}/installer/boot.ipxe
          #!ipxe
          kernel ${bootWebroot}/${arch}/installer/kernel init=${toString installers."${arch}".config.system.build.toplevel}/init ${toString installers."${arch}".config.boot.kernelParams} \''${cmdline}
          initrd ${bootWebroot}/${arch}/installer/initrd
          imgstat
          boot
          EOF
        '';
      in
      builtins.concatStringsSep "\n" [
        "runHook preBuild"
        (builtins.concatStringsSep "\n" (map mkArchDir [ "x86_64" "aarch64" ]))
        ''
          cat << EOF > $out/boot.ipxe
          #!ipxe
          iseq \''${buildarch} arm64 && chain ${bootWebroot}/aarch64/installer/boot.ipxe || echo
          iseq \''${buildarch} x86_64 && chain ${bootWebroot}/x86_64/installer/boot.ipxe || goto err

          exit

          :err
          echo "Unknown architecture, aborting."
          exit
          EOF
        ''
        "\nrunHook postBuild"
      ];
  };
in
{
  services.dnsmasq = {
    settings = {
      enable-tftp = true;
      tftp-root = "${tftp-root}";

      # set tag 'ipxe' if request comes from iPXE (user class)
      dhcp-userclass = "set:ipxe,iPXE";
      # reference: https://datatracker.ietf.org/doc/html/rfc4578#section-2.1
      dhcp-match = [
        "set:efi-x86_64,option:client-arch,7"
        "set:efi-x86_64,option:client-arch,9"
        "set:efi-aarch64,option:client-arch,3"
      ];

      # disallow multicast and broadcast discovery, and ask to download boot file immediately
      # dhcp-option = [ "vendor:PXEClient,6,2b" ];

      dhcp-boot = [
        # if request comes from firmware, load iPXE over TFTP
        "tag:!ipxe,tag:efi-x86_64,x86_64/ipxe.efi"
        # TODO: find a way to determine if client is actually aarch64, not just guess at last
        "tag:!ipxe,tag:!efi-x86_64,aarch64/ipxe.efi"

        # if request comes from iPXE, direct it to bootstrap script
        "tag:ipxe,${bootWebroot}/boot.ipxe"
        # "tag:ipxe,https://boot.netboot.xyz/"
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

  services.nfs.server = {
    enable = true;
    exports = ''
      /nix/store *(ro,nohide,insecure,no_subtree_check)
    '';
  };
}
