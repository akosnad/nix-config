{
  flake.modules.nixos."hosts/kratos" = {
    services.printing = {
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      listenAddresses = [ "*:631" ];
      openFirewall = true;
    };
    hardware.printers = {
      ensurePrinters = [{
        name = "Zebra_Technologies_ZTC_ZD410-203dpi_ZPL";
        deviceUri = "usb://Zebra%20Technologies/ZTC%20ZD410-203dpi%20ZPL?serial=50J201702969";
        model = "drv:///sample.drv/zebra.ppd";
      }];
    };
  };
}
