{ lib, ... }:
{
  flake.modules.homeManager.desktop = { pkgs, ... }: {
    vdirsyncer.enable = true;
    programs.vdirsyncer.enable = true;

    accounts = {
      calendar = {
        basePath = ".dav/calendars";
        accounts = rec {
          personal = {
            primary = true;
            remote = {
              type = "caldav";
              userName = "akosnad";
              url = "https://dav.fzt.one/caldav/principal/akosnad/15995b03-0618-4950-8b82-cf155b5c4a47";
              passwordCommand = [ (lib.getExe pkgs.sops) "decrypt" "--extract" "[\\\"dav-token\\\"]" "${./secrets.yaml}" ];
            };
            vdirsyncer = {
              enable = true;
              itemTypes = [ "VEVENT" ];
            };
            khal = {
              enable = true;
              color = "#3584e4";
              priority = 100;
            };
          };
          personal_journal = {
            inherit (personal) remote;
            local.path = "/home/akos/.dav/journals/personal";
            vdirsyncer = {
              enable = true;
              itemTypes = [ "VJOURNAL" "VTODO" ];
            };
          };

          vill = {
            inherit (personal) vdirsyncer;
            remote = {
              inherit (personal.remote) type userName passwordCommand;
              url = "https://dav.fzt.one/caldav/principal/akosnad/bb594de4-cd57-4f63-a994-74afd2483a30";
            };
            khal = {
              enable = true;
              color = "#ff7800";
              priority = 80;
            };
          };
          vill_journal = {
            inherit (vill) remote;
            local.path = "/home/akos/.dav/journals/vill";
            vdirsyncer = {
              enable = true;
              itemTypes = [ "VJOURNAL" "VTODO" ];
            };
          };

          work = {
            inherit (personal) vdirsyncer;
            remote = {
              inherit (personal.remote) type userName passwordCommand;
              url = "https://dav.fzt.one/caldav/principal/akosnad/7c21347d-38ca-49dd-95ba-64191736145e";
            };
            khal = {
              enable = true;
              color = "#deddda";
              priority = 50;
            };
          };
          work_journal = {
            inherit (work) remote;
            local.path = "/home/akos/.dav/journals/work";
            vdirsyncer = {
              enable = true;
              itemTypes = [ "VJOURNAL" "VTODO" ];
            };
          };

          holidays = {
            remote = {
              type = "http";
              url = "https://calendar.google.com/calendar/ical/en.hungarian%23holiday%40group.v.calendar.google.com/public/basic.ics";
            };
            vdirsyncer = {
              enable = true;
              conflictResolution = "remote wins";
            };
            khal = {
              enable = true;
              readOnly = true;
              color = "#e01b24";
              priority = 40;
            };
          };

          bdays = {
            remote = {
              inherit (personal.remote) type userName passwordCommand;
              url = "https://dav.fzt.one/caldav/principal/akosnad/_birthdays_e3dfe17a-66dd-459d-9aa6-a3f63c25addd";
            };
            vdirsyncer = {
              enable = true;
              conflictResolution = "remote wins";
            };
            khal = {
              enable = true;
              readOnly = true;
              color = "#33d17a";
              priority = 30;
            };
          };
        };
      };

      contact = {
        basePath = ".dav/contacts";
        accounts = rec {
          personal = {
            remote = {
              type = "carddav";
              userName = "akosnad";
              url = "https://dav.fzt.one/carddav/principal/akosnad/e3dfe17a-66dd-459d-9aa6-a3f63c25addd";
              passwordCommand = [ (lib.getExe pkgs.sops) "decrypt" "--extract" "[\\\"dav-token\\\"]" "${./secrets.yaml}" ];
            };
            vdirsyncer.enable = true;
            khard.enable = true;
          };
          vill = {
            inherit (personal) vdirsyncer khard;
            remote = {
              inherit (personal.remote) type userName passwordCommand;
              url = "https://dav.fzt.one/carddav/principal/akosnad/763cb978-a37a-474f-b8c3-4fd319dcecdd";
            };
          };
          work = {
            inherit (personal) vdirsyncer khard;
            remote = {
              inherit (personal.remote) type userName passwordCommand;
              url = "https://dav.fzt.one/carddav/principal/akosnad/15f97346-e1b2-43a1-acc4-15962404c6a8";
            };
          };
        };
      };
    };

    xdg.configFile."fzf-vjour/config".text = ''
      ROOT=~/.dav/journals
      COLLECTION_LABELS="personal=personal;vill=vill;work=work"
      SYNC_CMD="vdirsyncer sync"
    '';
    home.packages = [ pkgs.fzf-vjour ];

    programs.zsh.shellAliases = {
      note = "fzf-vjour";
      c = "khal";
      ic = "ikhal";
      co = "khard";
    };

    home.persistence."/persist".directories = [
      {
        directory = ".dav";
        mode = "u=rwx,g=,o=";
      }
      {
        directory = ".local/share/vdirsyncer";
        mode = "u=rwx,g=,o=";
      }
    ];
  };

  flake.modules.nixos.desktop = {
    services.restic.backups.persist.exclude = [
      "/persist/home/akos/.dav"
    ];
  };
}
