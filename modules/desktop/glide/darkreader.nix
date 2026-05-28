{
  flake.modules.homeManager.desktop = { pkgs, ... }: {
    programs.glide-browser.profiles.personal.extensions = {
      packages = with pkgs.firefox-addons; [
        # this is our locally patched version
        darkreader
      ];

      settings."addon@darkreader.org".settings =
        {
          # reference: https://github.com/darkreader/darkreader/blob/0a5014aee7059554ffea04ca349fdef6ee831894/src/defaults.ts#L71
          # also see the exported settings json

          schemeVersion = 2;
          installation = {
            date = 0;
            reason = "install";
            inherit (pkgs.firefox-addons.darkreader) version;
          };
          fetchNews = false;
          syncSettings = false;
          changeBrowserTheme = false;
          enabledByDefault = true;
          automation = {
            enabled = true;
            mode = "system";
            behavior = "OnOff";
          };
          disabledFor = [ ];
          enabledFor = [ ];
        };
    };
  };
}
