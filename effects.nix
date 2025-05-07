{ config, withSystem, ... }:
let
  hosts = builtins.attrNames config.flake.nixosConfigurations;
in
{
  herculesCI = herculesCI: {
    onPush.default.outputs.effects.nixos-upgrade-trigger = withSystem config.defaultEffectSystem (
      { pkgs, hci-effects, ... }:
      hci-effects.runIf (herculesCI.config.repo.branch == "main") (
        hci-effects.mkEffect {
          effectScript = ''
            echo "${builtins.toJSON { inherit (herculesCI.config.repo) branch tag rev; inherit hosts; }}"
            echo "notifying known hosts about update..."
            for host in ${builtins.concatStringsSep " " hosts}; do
              echo -n trying "$host"...
              ${pkgs.lib.getExe pkgs.curl} -s \
                --connect-timeout 15 \
                --max-time 30 \
                http://"$host":9000/hooks/nixos-upgrade-trigger \
                && echo " success." \
                || echo " failed."
            done
          '';
        }
      )
    );
  };
}
