#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix sops ssh-to-age openssh yq-go fd openssl
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
  platform="$(_target uname -s)"
  if [[ $platform != "Linux" ]]; then
    echo Host platform "$platform" is not suported, refusing to continue.
    exit 1
  fi

  mkdir -p "./modules/hosts/$hostname"

  cat >"./modules/hosts/$hostname/default.nix" <<EOF
{ lib, config, ... }:
{
  flake.modules.nixos."hosts/$hostname" = {
    imports = with config.flake.modules.nixos; [
      # profiles
      base
      akos

      # boot
      ephemeral-btrfs
    ] ++ [{
      home-manager.users.akos = {
        imports = with config.flake.modules.homeManager; [
          # profiles
          base
          akos
        ];
      };
    }];

    networking.hostName = "${hostname}";
    systemd.machineId = "$(openssl rand -hex 16)";

    system.stateVersion = "24.11";
  };
}
EOF

  cat >"./modules/hosts/$hostname/hardware.nix" <<EOF
{ lib, ... }:
{
  flake.modules.nixos."hosts/$hostname" = {
    hardware.facter.reportPath = lib.mkIf (builtins.pathExists ./facter.json) ./facter.json;
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
EOF

  ssh_key="ssh_host_ed25519_key"
  ssh-keygen -t ed25519 -N '' -C "${hostname}" -f "./modules/hosts/${hostname}/$ssh_key"

  if yq -e ".keys.hosts | filter(. | anchor == \"${hostname}\") | .[]" .sops.yaml &>/dev/null; then
    echo "host age key for ${hostname} already present in .sops.yaml, refusing to overwrite."
    exit 1
  fi

  age_key="$(ssh-to-age -i "./modules/hosts/${hostname}/${ssh_key}.pub")"
  printf "Generated system age key:\n\n%s\n\n" "$age_key"
  yq -e ".keys.hosts += (\"${age_key}\" | . anchor = \"${hostname}\")" -i .sops.yaml
  yq -e "with(.creation_rules[]; . | select(.path_regex == \"hosts/common/secrets.ya?ml\$\") | .key_groups.[0].age += (\"dummy\" | . alias = \"${hostname}\"))" -i .sops.yaml
  fd 'secrets.ya?ml' -x sops updatekeys -y
}

populate_config_efi() {
  cat >"./modules/hosts/$hostname/disks.nix" <<EOF
{
  flake.modules.nixos."hosts/$hostname" = {
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
  };
}
EOF
}

populate_config_bios() {
  cat >"./modules/hosts/$hostname/boot.nix" <<EOF
{ lib, config, ... }:
{
  flake.modules.nixos."hosts/$hostname" = {
    boot.loader = {
      systemd-boot.enable = lib.mkForce false;
      grub.enable = lib.mkForce true;
    };
  };
}
EOF

  cat >"./modules/hosts/$hostname/disks.nix" <<EOF
{
  flake.modules.nixos."hosts/$hostname" = {
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
  };
}
EOF
}

install_system() {

  temp="$(mktemp -d)"
  install -d -m755 "$temp/persist/etc/ssh"
  cp "./modules/hosts/${hostname}/ssh_host_ed25519_key" "./modules/hosts/${hostname}/ssh_host_ed25519_key.pub" "$temp/persist/etc/ssh"

  nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --generate-hardware-config nixos-facter "./modules/hosts/${hostname}/facter.json" --flake ".#${hostname}" --target-host "root@${target_host}"

  shred -u "./modules/hosts/${hostname}/ssh_host_ed25519_key"

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
  populate_config_common
  if [[ $boot_mode == "bios" ]]; then
    populate_config_bios
  else
    populate_config_efi
  fi
  echo "Configuration for ${hostname} has been generated."
  echo
  echo "Now is a good time to make adjustments to it."
  echo "After that, do the following:"
  echo "- add the new files to VCS because nix will ignore ones that aren't tracked!"
  echo "- re-run this script to start installation."
fi
