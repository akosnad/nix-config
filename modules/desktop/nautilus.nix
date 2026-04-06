{
  config.flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      services.gvfs.enable = true;
      environment.systemPackages = with pkgs; [ nautilus ];
      programs.nautilus-open-any-terminal.enable = true;
    };
}
