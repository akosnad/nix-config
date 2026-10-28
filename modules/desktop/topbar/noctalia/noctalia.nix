{ lib, ... }:
let
  inherit (lib) types;
in
{
  flake.modules.homeManager.noctalia = {
    imports = [ ./_module-backport ];
    options.accounts.calendar.accounts = lib.mkOption {
      type = types.attrsOf (
        types.submodule [
          (import ./_module-backport/accounts.nix )
        ]
      );
    };

    config = {
      programs.noctalia = {
        enable = true;
      };
    };
  };

  flake.modules.nixos.noctalia = { pkgs, ... }: {
    xdg.sounds.enable = true;

    # TODO: migrate to programs.noctalia module after 26.11
    # taken from: https://github.com/NixOS/nixpkgs/blob/31ecbaca1bdefa45dffc409f0250bd8039ea0010/nixos/modules/programs/wayland/noctalia.nix#L44-L58
    systemd.user.services.noctalia = {
      description = "Noctalia Wayland desktop shell";
      documentation = [ "https://docs.noctalia.dev/v5/" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      enableDefaultPath = false;

      serviceConfig = {
        ExecStart = lib.getExe pkgs.noctalia;
        Restart = "on-failure";
      };
    };
  };
}
