{
  flake.modules.homeManager.desktop = { pkgs, ... }:
    let
      inherit (pkgs.nur.repos.rycee.firefox-addons) ublock-origin;
      inherit (ublock-origin.passthru) addonId;
    in
    {
      programs.glide-browser = {
        profiles.personal.extensions.packages = [ ublock-origin ];
        policies."3rdparty".Extensions.${addonId} = {
          # reference: https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin:-configuration
          toOverwrite.filterLists = [
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "easyprivacy"
            "urlhaus-1"
            "plowe-0"
            "fanboy-ai-suggestions"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "easylist-annoyances"
            "HUN-0"
          ];

          toOverwrite.trustedSiteDirectives = [
            "chrome-extension-scheme"
            "moz-extension-scheme"

            "/.*\\.localhost/"
            "localhost"
            "/.*\\.home\\.arpa/"
            "home.arpa"

            "accountscenter.facebook.com"
            "app.element.io"
            "arveres.bkv.hu"
            "base.kompaas.tech"
            "services.kompaas.tech"
            "clan.lol"
            "copilot.microsoft.com"
            "demo.beta.seamlessaccess.org"
            "eteltazeletert.hu"
            "link.springer.com"
            "predictabledesigns.com"
            "samplefocus.com"
            "shop.traconelectric.com"
            "speed.cloudflare.com"
            "teams.live.com"
            "teams.microsoft.com"
            "tidal.com"
            "tracking.expressone.hu"
            "www.kawasaki.hu"
          ];

          toOverwrite.filters = [
            "outlook.live.com###LeftRail"
            # copilot buttons
            "outlook.live.com##.f1m7nsj4.fksc0bp.f10pi13n.f1a3p1vp.f1ft4266.f14t3ns0.f1hg901r.f1atq3b4.f1fj1oij.f1hr7we4.___11f3rcj"
            "outlook.live.com##button.lxLVy.r1f29ykk.fui-Button:nth-of-type(1)"

            "gls-group.eu##.slide.carousel.campaign-banner"

            "telex.hu##.modal--tax__container"
            "telex.hu##.recommendation--pr.recommendation"
            "telex.hu##.telex-links"

            "www.tag-connect.com###hu-outer-wrapper > .hu-wrapper"

            "www.linkedin.com##.pv3"

            "grizzlytools.shop##._loaded_f2sah_60._modalOverlay_f2sah_1"

            # youtube shorts and other annoying content in main page
            "www.youtube.com##ytd-reel-shelf-renderer.ytd-item-section-renderer.style-scope"
            # popup?
            "www.youtube.com##ytd-rich-section-renderer.ytd-rich-grid-renderer.style-scope"
            "www.youtube.com##grid-shelf-view-model.ytGridShelfViewModelHostHasBottomButton.ytd-item-section-renderer.ytGridShelfViewModelHost"

            "||3.pcx.hu/images/design/design25/BCK_elem.png$image"

            "ncore.pro##div#main_tartalom > center:has(img)"
            "ncore.pro##div#main_tartalom > center:has(.banner)"

            "rutracker.net##div.bn-idx:nth-of-type(1)"
            "rutracker.net##div.bn-idx:nth-of-type(3)"
            "rutracker.net##.ext-links.bn-idx"
            "rutracker.net###bn-top-right"
            "rutracker.net##[href^=\"https://robinbob.in/\"]"

            "www.donpepe.hu##.swal2-backdrop-show.swal2-center.swal2-container"

            "www.patreon.com###transcend-consent-manager"
          ];
        };
      };
    };
}
