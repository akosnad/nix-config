#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix sops ssh-to-age openssh yq-go
set -o pipefail
set -o errexit

hostname="$1"
target_host="$2"
target_disk="$3"
boot_mode="$4"

if [[ $target_host == "" || $hostname == "" || $target_disk == "" ]]; then
  echo "Usage: $0 <hostname> <target_host> <target_disk> [boot_mode]"
  echo
  echo "boot_mode is one of 'efi' or 'bios'. defaults to 'efi'"
  echo
  echo "Prerequisites:"
  echo "- boot the target machine to a nixos installer"
  echo "- change root password to be able to log in via ssh"
  exit 1
fi

if [ -n "$boot_mode" ]; then
  if [[ $boot_mode != "bios" && $boot_mode != "efi" ]]; then
    echo "boot_mode is invalid. allowed values: efi, bios."
    exit 1
  fi
fi

populate_config_common() {
  mkdir -p "./home/akos"

  if [ -f "./home/akos/${hostname}.nix" ]; then
    echo "./home/akos/${hostname}.nix already exists, refusing to overwrite."
    exit 1
  fi

  cat >"./home/akos/${hostname}.nix" <<EOF
{
  imports = [
    ./global
  ];
}
EOF

  machine="$(_target uname -m)"
  platform="$(_target uname -s)"
  if [[ $platform != "Linux" ]]; then
    echo Host platform "$platform" is not suported, refusing to continue.
    exit 1
  fi
  hostPlatform="${machine}-linux"
  cat >"./hosts/${hostname}/hardware-configuration.nix" <<EOF
# This is a placeholder until nixos-anywhere generates this for us.
{
  nixpkgs.hostPlatform = "${hostPlatform}";
}
EOF

  ssh_key="ssh_host_ed25519_key"
  ssh-keygen -t ed25519 -N '' -C "${hostname}" -f "./hosts/${hostname}/$ssh_key"

  if yq -e ".keys.hosts | filter(. | anchor == \"${hostname}\") | .[]" .sops.yaml &>/dev/null; then
    echo "host age key for ${hostname} already present in .sops.yaml, refusing to overwrite."
    exit 1
  fi

  age_key="$(ssh-to-age -i "./hosts/${hostname}/${ssh_key}.pub")"
  printf "Generated system age key:\n\n%s\n\n" "$age_key"
  yq -e ".keys.hosts += (\"${age_key}\" | . anchor = \"${hostname}\")" -i .sops.yaml
  yq -e "with(.creation_rules[]; . | select(.path_regex == \"hosts/common/secrets.ya?ml\$\") | .key_groups.[0].age += (\"dummy\" | . alias = \"${hostname}\"))" -i .sops.yaml
  sops -i -r --add-age "${age_key}" hosts/common/secrets.yaml
}

populate_config_efi() {

  mkdir -p "./hosts/$hostname"

  cat >"./hosts/$hostname/default.nix" <<EOF
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix

    ../common/users/akos
  ];

  networking.hostName = "${hostname}";

  system.stateVersion = "24.11";
}
EOF

  cat >"./hosts/$hostname/disk-config.nix" <<EOF
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${target_disk}";
        content = {
          type = "gpt";
          partitions = {

            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "513M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "btrfs";
                mountOptions = [ "noatime" "compress=zstd" "space_cache=v2" "discard" ];
                subvolumes = {
                  "@root" = { mountpoint = "/"; };
                  "@old_roots" = { };
                  "@nix" = { mountpoint = "/nix"; };
                  "@persist" = { mountpoint = "/persist"; };
                  "@swap" = { mountpoint = "/swap"; };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
EOF
}

populate_config_bios() {

  mkdir -p "./hosts/$hostname"

  cat >"./hosts/$hostname/default.nix" <<EOF
{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix

    ../common/users/akos
  ];

  networking.hostName = "${hostname}";

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = lib.mkForce true;
  };

  system.stateVersion = "24.11";
}
EOF

  cat >"./hosts/$hostname/disk-config.nix" <<EOF
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${target_disk}";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for GRUB MBR
            };

            ESP = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "btrfs";
                mountOptions = [ "noatime" "compress=zstd" "space_cache=v2" "discard" ];
                subvolumes = {
                  "@root" = { mountpoint = "/"; };
                  "@old_roots" = { };
                  "@nix" = { mountpoint = "/nix"; };
                  "@persist" = { mountpoint = "/persist"; };
                  "@swap" = { mountpoint = "/swap"; };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
EOF
}

install_system() {

  temp="$(mktemp -d)"
  install -d -m755 "$temp/persist/etc/ssh"
  cp "./hosts/${hostname}/ssh_host_ed25519_key" "./hosts/${hostname}/ssh_host_ed25519_key.pub" "$temp/persist/etc/ssh"

  nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --generate-hardware-config nixos-generate-config "./hosts/${hostname}/hardware-configuration.nix" --flake ".#${hostname}" --target-host "root@${target_host}"

  shred -u "./hosts/${hostname}/ssh_host_ed25519_key"

}

ssh_control="$(mktemp -d)"
remote="root@${target_host}"

cleanup() {
  ssh -o ControlMaster=auto -o ControlPath="$ssh_control/%C" -O exit "$remote" &>/dev/null || true
  rm -rf "$ssh_control"
}
trap cleanup EXIT

# prompt for password, then go background. this connection can later be reused
ssh -o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPath="$ssh_control/%C" -o ControlPersist=600 -M -f "$remote" sleep infinity
_target() {
  ssh -o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPath="$ssh_control/%C" "$remote" "$@"
}

_config_hostname="$(nix eval --raw .\#nixosConfigurations."${hostname}".config.networking.hostName 2>/dev/null || true)"
if [[ $_config_hostname == "$hostname" ]]; then
  echo "Configuration for $hostname seems to already exist, starting installation..."
  install_system
else
  if [[ $boot_mode == "bios" ]]; then
    populate_config_bios
  else
    populate_config_efi
  fi
  populate_config_common
  echo "Configuration for ${hostname} has been generated."
  echo
  echo "Now is a good time to make adjustments to it."
  echo "After that, do the following:"
  echo "- add the new files to VCS because nix will ignore ones that aren't tracked!"
  echo "- re-run this script to start installation."
fi
