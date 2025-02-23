{ config, lib, ... }:
let
  mkEndpoint = ext: ''
    [${ext}]
    type=endpoint
    context=from-internal
    disallow=all
    allow=alaw
    auth=${ext}
    aors=${ext}
    acl=internal-only

    [${ext}]
    type=auth
    auth_type=userpass
    password=${ext}
    username=${ext}

    [${ext}]
    type=aor
    max_contacts=1
  '';
in
{
  services.asterisk = {
    enable = true;
    extraArguments = [ ];
    extraConfig = ''
      [options]
      verbose=5
      debug=3
    '';
    useTheseDefaultConfFiles = [ ];
    confFiles = {
      "logger.conf" = /* asterisk */ ''
        [general]
        dateformat=%F %T

        [logfiles]
        messages => security,notice,warning,error
        security => security
        console => security,notice,warning,error
        syslog.local0 => security,notice,warning,error
      '';
      "musiconhold.conf" = /* asterisk */ ''
        [default]
        mode=files
        directory=/var/lib/asterisk/moh_custom
        random=yes
      '';
      "extensions.conf" = /* asterisk */ ''
        [from-internal]
        exten = 100,1,Answer()
        same = n,Wait(1)
        same = n,Playback(hello-world)
        same = n,Hangup()

        ; let the extensions dial each other
        [from-internal]
        exten => _6XXX,1,Dial(PJSIP/''${EXTEN},10)
         same => n,VoiceMail(''${EXTEN}@internal)
         same => n,PlayBack(vm-goodbye)
         same => n,HangUp()

        ; allow dialing out
        [from-internal]
        exten = _06XXXXXXXXX,1,Dial(PJSIP/''${EXTEN}@trunk)
        exten = _06XXXXXXXX,1,Dial(PJSIP/''${EXTEN}@trunk)
        exten = _36XXXXXXXXX,1,Dial(PJSIP/''${EXTEN}@trunk)
        exten = _36XXXXXXXX,1,Dial(PJSIP/''${EXTEN}@trunk)

        ; internal voicemail
        [from-internal]
        exten => 999,1,VoiceMailMain(''${CALLERID(num)}@internal,s)

        [from-external]
        exten => s,1,Log(NOTICE, Incoming call from external source)
         same => n,Log(NOTICE, Caller ID: ''${CALLERID(num)})
         same => n,Answer()
         same => n,Dial(PJSIP/6001&PJSIP/6002,37:4,m(default))
         same => n,VoiceMail(6001@internal)
         same => n,PlayBack(vm-goodbye)
         same => n,Hangup()

      '';
      "voicemail.conf" = /* asterisk */ ''
        [general]
        aliasescontext=aliases
        
        [internal]
        6001 => 100,Default Mailbox,akos@localhost
        6002 => 6001@internal

        [aliases]
        6002@devices => 6001@internal
      '';
      "acl.conf" = /* asterisk */ ''
        [internal-only]
        deny=0.0.0.0/0.0.0.0
        permit=10.0.0.0/255.0.0.0
      '';
      "pjsip.conf" = builtins.concatStringsSep "\n"  /* asterisk */ ([
        ''
          [transport-udp]
          type=transport
          protocol=udp
          bind=0.0.0.0

          #include ${config.sops.secrets.asterisk-trunk-config.path}
        ''
      ] ++ [
        (mkEndpoint "6001")
        (mkEndpoint "6002")
        (mkEndpoint "6003")
      ]);
    };
  };

  systemd.services.asterisk = {
    reloadIfChanged = true;
  };

  services.fail2ban.jails.asterisk.settings = {
    filter = "asterisk";
    logpath = "/var/log/asterisk/security";
    ignoreIP = lib.concatStringsSep " " (
      config.services.fail2ban.ignoreIP ++ [
        # allow SIP trunk
        "185.66.52.11"
      ]
    );
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/asterisk";
      mode = "750";
      user = "asterisk";
      group = "asterisk";
    }
    {
      directory = "/var/spool/asterisk";
      mode = "750";
      user = "asterisk";
      group = "asterisk";
    }
  ];

  sops.secrets.asterisk-trunk-config = {
    sopsFile = ./secrets.yaml;
    owner = "asterisk";
    group = "asterisk";
    mode = "600";
  };

  networking.firewall = {
    allowedUDPPorts = [
      # SIP, IAX, IAX2, MGCP
      5060
      5061
      4569
      5036
      2727
    ];
    allowedUDPPortRanges = [{
      # RTP
      from = 10000;
      to = 20000;
    }];
  };
}
