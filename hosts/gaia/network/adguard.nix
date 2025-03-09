{ config, lib, ... }:
let
  localhostHostEntries = lib.filterAttrs (ip: _: ip == "::1" || ip == "127.0.0.1" || ip == "127.0.0.2") config.networking.hosts;
  localhostHostsValues = lib.mapAttrsToList (_: hosts: hosts) localhostHostEntries;
  localhostHosts = lib.unique (lib.flatten localhostHostsValues);
  localhostNetworkHosts = builtins.filter (host: host != "localhost") localhostHosts;

  mkHostRewrite = ip: host: {
    domain = host;
    answer = ip;
  };
  lanIp = config.devices.gaia.ip;
  mkLocalhostRewrite = mkHostRewrite lanIp;

  localhostHostsRewrites = builtins.map mkLocalhostRewrite localhostNetworkHosts;

  devices = builtins.attrValues config.devices;
  mapExtraHostname = d: h: [ (mkHostRewrite d.ip h) (mkHostRewrite d.ip "${h}.${config.networking.domain}") ];
  devicesExtraHostnames = map (d: map (mapExtraHostname d) d.extraHostnames) devices;

  hostRewrites = localhostHostsRewrites ++ (lib.flatten devicesExtraHostnames);
in
{
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = {
      http.session_ttl = 720;
      dhcp.enabled = false;
      querylog = {
        enabled = true;
        interval = "24h";
      };
      statistics = {
        enabled = true;
        interval = "24h";
      };
      dns = {
        bind_hosts = [ config.devices.gaia.ip ];
        protection_enabled = true;
        upstream_dns = [
          "# https://cloudflare-dns.com/dns-query"
          "# https://dns10.quad9.net/dns-query"
          "# https://dns.google/dns-query"
          "1.1.1.1"
          "1.0.0.1"
          "84.2.46.1"
          "84.2.44.1"
          "8.8.8.8"
          "8.8.4.4"
        ];
        bootstrap_dns = [
          "1.1.1.1"
          "1.0.0.1"
          "8.8.8.8"
          "8.8.4.4"
        ];
        blocked_hosts = [
          "version.bind"
          "id.server"
          "hostname.bind"
          "wpad.local"
          "wpad.${config.networking.domain}"
        ];
        use_private_ptr_resolvers = true;
        local_ptr_upstreams = [
          "127.0.0.1:5953"
        ];
      };
      user_rules = [
        # unblock some used sites
        "@@||plex.tv^"
        "@@||youtube.com^"
        "@@||www.dreamaquarium.com^$important"

        ## unblock needed services
        # Geotastic online game
        "@@||geotastic.net^$important"
        # Xiaomi phones don't work without this one
        "@@||api.io.mi.com^$important"
        # mail list/newsletter service
        "@@||mlsend.com^$important"

        # block rekordbox from trying to validate license :P
        "||cloud.kuvo.com^"
        "||rb-share.kuvo.com^"
        "||accounts.us1.gigya.com^"
        "||us1.gigya.com^"

        # block synplant plugin from trying to validate license :P
        "||nuedge.net^"
        "||soniccharge.com^"
      ];
      filtering.rewrites = hostRewrites;
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adaway.org/hosts.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
        {
          enabled = true;
          url = "https://someonewhocares.org/hosts/zero/hosts";
          name = "Dan Pollock's List";
          id = 1656881098;
        }
        {
          enabled = true;
          url = "https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-agh-online.txt";
          name = "Online Malicious URL Blocklist";
          id = 1656881099;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/mitchellkrogza/The-Big-List-of-Hacked-Malware-Web-Sites/master/hosts";
          name = "The Big List of Hacked Malware Web Sites";
          id = 1656881100;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt";
          name = "NoCoin Filter List";
          id = 1656881101;
        }
        {
          enabled = false;
          url = "https://abp.oisd.nl/basic/";
          name = "OISD Blocklist Basic";
          id = 1656881102;
        }
        {
          enabled = false;
          url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt";
          name = "Dandelion Sprout's Anti-Malware List";
          id = 1656881103;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/adguard.txt";
          name = "Scam Blocklist by DurableNapkin";
          id = 1656881104;
        }
        {
          enabled = true;
          url = "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=1&mimetype=plaintext";
          name = "Peter Lowe's List";
          id = 1656881105;
        }
        {
          enabled = false;
          url = "https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/youtubelist.txt";
          name = "Youtube Ads";
          id = 1679948977;
        }
      ];
    };
  };

  services.nginx.virtualHosts.gaia.locations."/adguard" = {
    proxyPass = "http://127.0.0.1:3000/";
  };
}
