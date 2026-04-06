{
  config.flake.modules.nixos."hosts/kratos" =
    { pkgs, ... }:
    {
      home-manager.users.akos = {
        home.packages = with pkgs; [
          gimp3
          inkscape
        ];

        home.persistence."/persist".directories = [
          ".local/share/Steam"
          ".local/share/lutris"
          "Games"
        ];
      };
    };
}
