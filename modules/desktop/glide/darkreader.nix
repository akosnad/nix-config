{
  flake.modules.homeManager.desktop = { pkgs, ... }:
    let
      # this is our locally patched version
      inherit (pkgs.firefox-addons) darkreader;
      inherit (darkreader.passthru) addonId;
    in
    {
      programs.glide-browser.profiles.personal.extensions = {
        packages = [ darkreader ];
        settings.${addonId}.settings =
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
            enabledFor = [
              "academy.fpblock.com"
            ];
            disabledFor = [
              "microsoftedge.microsoft.com"
              "app.element.io"
              "github.com"
              "portal.azure.com"
              "copilot.microsoft.com"
              "localhost:3000"
              "tailwindcss.com"
              "www.facebook.com"
              "fzt.one"
              "dash.cloudflare.com"
              "neptun2.ppke.hu"
              "urbit.fzt.one"
              "tinted-theming.github.io"
              "www.google.com"
              "hyperion.home.arpa"
              "en.wikipedia.org"
              "gist.github.com"
              "teams.microsoft.com"
              "ppke.sharepoint.com"
              "forms.office.com"
              "neptun3.ppke.hu"
              "linustechtips.com"
              "www.youtube.com"
              "frigate.home.arpa"
              "clan.lol"
              "docs.robotnix.org"
              "hyperion:32400"
              "nmattia.com"
              "docs.github.com"
              "internetbank.otpbank.hu"
              "vite-pwa-org.netlify.app"
              "bitpay.com"
              "portfolio.metamask.io"
              "cctc.hu"
              "www.bku.hu"
              "search.nixos.org"
              "mail.notion.so"
              "eteltazeletert.hu"
              "chatgpt.com"
              "docs.rs"
              "www.floatplane.com"
              "developer.spotify.com"
              "docs.rust-embedded.org"
              "www.home-assistant.io"
              "pygments.org"
              "app.diagrams.net"
              "arveres.bkv.hu"
              "docs.esp-rs.org"
              "onedrive.live.com"
              "scholar.google.com"
              "listen.tidal.com"
              "localhost:8088"
              "esphome.io"
              "albert.lol"
              "login.tidal.com"
              "nixcademy.com"
              "futar.bkk.hu"
              "elife-asu.github.io"
              "calendar.google.com"
              "matrix.org"
              "www.wolframalpha.com"
              "www.geogebra.org"
              "raphsilva.github.io"
              "kicanvas.org"
              "solutions.mccsemi.com"
              "www.researchgate.net"
              "miniflux.akosnad.dev"
              "akosnad.dev"
              "l-eloszoba.home.arpa"
              "nyakexpressz.hu"
              "calendar.notion.so"
              "casambi.com"
              "www.canva.com"
              "onlinesmithchart.com"
              "docs.google.com"
              "formlabs.com"
              "teams.live.com"
              "talks.nixcon.org"
              "www.fusionems.eu"
              "garnix.io"
              "api.hestore.hu"
              "nix-community.github.io"
              "eotvos-gyal.edu.hu"
              "www.fizetesek.hu"
              "telephony.kompaas.tech"
              "demo.inventree.org"
              "deepwiki.com"
              "www.falstad.com"
              "tonsky.me"
              "webench.ti.com"
              "10.99.63.26"
              "idopontfoglalo.kh.gov.hu"
              "inventree.localhost"
              "10.99.232.227"
              "www.scribd.com"
              "www.electronics-tutorials.ws"
              "ground.news"
              "web.archive.org"
              "electronics.stackexchange.com"
              "shop.ageta.hu"
              "player.nexiuslearning.com"
              "tubular.net"
              "redacted.sh"
              "music.home.arpa"
              "www.honda.hu"
              "www.mumush.world"
              "jellyseerr.home.arpa"
              "archive.softwareheritage.org"
              "portal.telnyx.com"
              "www.freertos.org"
              "issuetracker.google.com"
              "timeline.home.arpa"
              "www.maptiler.com"
              "gls-rtt.com"
              "10.99.92.166"
              "falstad.com"
              "demo.frigate.video"
            ];
          };
      };
    };
}
