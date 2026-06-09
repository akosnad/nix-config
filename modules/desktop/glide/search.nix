{
  flake.modules.homeManager.desktop = { pkgs, nixosConfig, config, ... }: {
    programs.glide-browser.profiles.personal = {
      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
        order = [ "ddg" "google" "bing" ];
        engines = {
          google.metaData.alias = "g";
          bing.metaData.alias = "b";
          wikipedia.metaData.alias = "w";

          nix-packages = {
            name = "Nix Packages";
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
                { name = "channel"; value = nixosConfig.system.nixos.release; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "n" ];
          };

          nixos-options = {
            name = "NixOS Options";
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "query"; value = "{searchTerms}"; }
                { name = "channel"; value = nixosConfig.system.nixos.release; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "no" ];
          };

          home-manager-options = {
            name = "Home Manager Options";
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "query"; value = "{searchTerms}"; }
                { name = "channel"; value = config.home.version.release; }
                { name = "source"; value = "home_manager"; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "hm" ];
          };

          noogle = {
            name = "Nixpkgs functions (noogle.dev)";
            urls = [{
              template = "https://noogle.dev/q";
              params = [{ name = "q"; value = "{searchTerms}"; }];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "nf" ];
          };

          rust-docs = {
            name = "Rust docs (docs.rs)";
            urls = [{ template = "https://docs.rs/{searchTerms}"; }];
            definedAliases = [ "rd" ];
          };

          rust-libs = {
            name = "Rust libs (lib.rs)";
            urls = [{
              template = "https://lib.rs/search";
              params = [{ name = "q"; value = "{searchTerms}"; }];
            }];
            definedAliases = [ "rl" ];
          };
        };
      };
    };
  };
}
