{
  flake.modules.homeManager.desktop = {
    programs.glide-browser.profiles.personal.glideTs = /* ts */ ''
      glide.keymaps.set("normal", "t", "tab_new");
      glide.keymaps.set("normal", "x", "tab_close");
      glide.keymaps.set("normal", "X", "tab_reopen");
    '';
  };
}
