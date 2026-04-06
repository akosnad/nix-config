{
  config.flake.modules.homeManager.linphone =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        linphone
      ];

      home.persistence."/persist".directories = [
        ".config/linphone"
        ".local/share/linphone"
      ];
    };
}
