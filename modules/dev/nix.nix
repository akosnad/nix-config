{
  config.flake.modules.homeManager.dev = { pkgs, ... }: {
    home.packages = with pkgs; [
      nix-output-monitor
    ];
  };
}
