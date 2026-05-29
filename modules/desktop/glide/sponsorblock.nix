{ lib, ... }:
{
  flake.modules.homeManager.desktop = { pkgs, ... }:
    let
      inherit (pkgs.nur.repos.rycee.firefox-addons) sponsorblock;
      inherit (sponsorblock.passthru) addonId;
    in
    {
      programs.glide-browser = {
        profiles.personal.extensions = {
          packages = [ sponsorblock ];
          settings.${addonId}.settings = {
            # reference: https://github.com/ajayyy/SponsorBlock/blob/94a7b2ec4eb8b315de629a560e1be11b0ccef526/src/config.ts#L591
            # and see settings export for values
            alreadyInstalled = true;

            skipRules =
              let
                # reference: https://wiki.sponsor.ajay.app/w/Advanced_skip_options
                # TODO: standalone options module?
                categoryRule = { category, action }: {
                  predicate = {
                    kind = "check";
                    attribute = "category";
                    operator = "==";
                    value = category;
                  };
                  skipOption = {
                    "show_only" = 0;
                    "manual_skip" = 1;
                    "auto_skip" = 2;
                  }.${action};
                  comments = [ ];
                };
                categoryRules = lib.mapAttrsToList (k: v: categoryRule { category = k; action = v; });
              in
              categoryRules {
                intro = "auto_skip";
                outro = "auto_skip";
                sponsor = "auto_skip";
                selfpromo = "manual_skip";
                exclusive_access = "show_only";
                interaction = "show_only";
                poi_highlight = "show_only";
                preview = "manual_skip";
                hook = "manual_skip";
                filler = "show_only";
                music_offtopic = "show_only";
              };
          };
        };
      };
    };
}
