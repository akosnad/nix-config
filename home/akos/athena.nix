{
  # You can import other home-manager modules here
  imports = [
    ./global
    ./features/desktop/hyprland
  ];

  programs.firefox = {
    enable = true;
  };
}
