{
  flake.modules.homeManager.desktop = { pkgs, ... }:
    let
      inherit (pkgs.nur.repos.rycee.firefox-addons) keepassxc-browser;
      inherit (keepassxc-browser.passthru) addonId;
    in
    {
      programs.glide-browser = {
        nativeMessagingHosts = [ pkgs.keepassxc ];
        profiles.personal.extensions = {
          packages = [ keepassxc-browser ];
          settings.${addonId} = {
            permissions = [
              # reference: https://github.com/keepassxreboot/keepassxc-browser#requested-permissions
              "activeTab"
              "contextMenus"
              "cookies"
              "clipboardWrite"
              "nativeMessaging"
              "notifications"
              "privacy"
              "storage"
              "tabs"
              "webNavigation"
              "webRequest"
              "webRequestBlocking"
              "http://*/*"
              "https://*/*"
              "https://api.github.com/"
              "<all_urls>"
            ];
            settings = {
              settings = {
                passkeys = true;
                passkeysFallback = true;
                defaultPasswordManager = true;
              };

              # this is stored in plaintext anyways on disk,
              # so storing it here proves no more risk.
              # 
              # the threat model is as follows:
              # knowing the connection parameters (stored here),
              # the attacker is still required to have arbitrary
              # code execution on the host where the database is opened.
              # this, i'm fine with.
              keyRing = {
                "8a0e8102614644349ec268a85ff16be4bdb12c16344277864f011a881a140450" = {
                  id = "nix-config: glide-browser common";
                  key = "wnYiIQGq9avInDCObRgCl1hXZys/k3xWuD5BbS3WSzc=";
                  hash = "8a0e8102614644349ec268a85ff16be4bdb12c16344277864f011a881a140450";
                  # created = 0;
                  # lastUsed = 0;
                };
              };
            };
          };
        };
      };
    };
}
