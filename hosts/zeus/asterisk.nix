let
  mkEndpoint = ext: ''
    [${ext}]
    type=endpoint
    context=from-internal
    disallow=all
    allow=ulaw
    auth=${ext}
    aors=${ext}

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
      "extensions.conf" = /* asterisk */ ''
        [from-internal]
        exten = 100,1,Answer()
        same = n,Wait(1)
        same = n,Playback(hello-world)
        same = n,Hangup()

        ; let the extensions dial each other
        [from-internal]
        exten = _6XXX,1,Dial(PJSIP/''${EXTEN})
      '';
      "pjsip.conf" = builtins.concatStringsSep "\n"  /* asterisk */ ([
        ''
          [transport-udp]
          type=transport
          protocol=udp
          bind=0.0.0.0
        ''
      ] ++ [
        (mkEndpoint "6001")
        (mkEndpoint "6002")
        (mkEndpoint "6003")
      ]);
    };
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/asterisk";
    mode = "750";
    user = "asterisk";
    group = "asterisk";
  }];
}
