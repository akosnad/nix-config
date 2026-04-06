{ inputs, config, ... }:
{
  config.flake.modules.nixos.arion =
    { pkgs, ... }:
    {
      imports = [
        inputs.arion.nixosModules.arion
        config.flake.modules.nixos.docker
      ];

      environment.systemPackages = with pkgs; [
        arion
      ];

      virtualisation.arion.backend = "docker";
    };
}
