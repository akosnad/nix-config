{
  config.flake.modules.homeManager.shell = { pkgs, ... }: {
    home.packages = [ pkgs.glances ];
  };

  # one of glances' deps is broken, so ignore the tests for now.
  # reference:
  # https://github.com/NixOS/nixpkgs/issues/500713
  # https://github.com/giampaolo/psutil/issues/2693
  # TODO: remove fix once this is resolved upstream
  config.flake.overlays.fix-glances = _final: prev: {
    glances = prev.glances.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
    };
  };
}
