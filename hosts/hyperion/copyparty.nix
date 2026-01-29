{
  services.copyparty = {
    enable = true;
    settings = { };
    volumes = {
      "/up" = {
        path = "/var/lib/copyparty/up";
        access = {
          # write-upget = see own uploads only
          wG = "*";
        };
        flags = {
          "e2d, d2t, fk" = 12;
        };
      };
      "/sandbox" = {
        path = "/var/lib/copyparty/sandbox";
        access = {
          rwmd = "*";
        };
      };
    };
  };
}
