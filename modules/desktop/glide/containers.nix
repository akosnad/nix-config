{
  flake.modules.homeManager.desktop = {
    programs.glide-browser.profiles.personal = {
      containersForce = true;
      containers = {
        nadudvari-backup = {
          id = 6;
          icon = "fingerprint";
          color = "blue";
        };
      };
    };
  };
}
