{
  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.relayHosts = [ "rd.fzt.one" ];
  };

  environment.persistence."/persist".directories = [ "/var/lib/private/rustdesk" ];
}
