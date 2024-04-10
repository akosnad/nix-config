{
  services.udev.extraRules = /* udev */ ''
    ## Prohibit turning off usb devices

    # Tesoro keyboard
    ACTION=="add", ATTRS{idVendor}=="195d", ATTRS{idProduct}=="2062", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="195d", ATTR{idProduct}=="2062", ATTR{power/autosuspend}="-1"
    # Logitech mouse
    ACTION=="add", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c53f", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c53f", ATTR{power/autosuspend}="-1"
  '';
}
