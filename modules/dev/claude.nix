let
  flake.modules.homeManager.claude =
    { pkgs, ... }:
    {
      # TODO: use HM module after upgrade to 25.11
      home.packages = with pkgs; [
        claude-code
      ];

      home.persistence."/persist" = {
        directories = [ ".claude" ];
        files = [ ".claude.json" ];
      };
    };

  flake.modules.homeManager.dev.imports = [ flake.modules.homeManager.claude ];
in
{
  inherit flake;
}
