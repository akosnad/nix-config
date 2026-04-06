{
  config.flake.modules.nixos.base =
    { lib, config, ... }:
    let
      inherit (lib) mkOption types;
      cfg = config.systemd.machineId;
    in
    {
      options.systemd.machineId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          16-byte/128-bit SystemD Machine ID.
          See https://www.freedesktop.org/software/systemd/man/latest/machine-id.html for details and its purpose.

          Default is null, which allows systemd to generate the ID on first boot. The file `/etc/machine-id` should be persisted in this case.
        '';
      };

      config.environment.etc.machine-id = {
        enable = cfg != null;
        text = "${cfg}\n";
        user = "+0";
        group = "+0";
        mode = "0444";
      };
    };
}
