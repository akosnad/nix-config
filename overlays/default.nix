{ inputs, ... }: {
  # Alias 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs
      (_: flake:
        let
          legacyPackages = (flake.legacyPackages or { }).${final.system} or { };
          packages = (flake.packages or { }).${final.system} or { };
          outPath = flake.outPath or { };
        in
        if legacyPackages != { } then legacyPackages else if packages != { } then packages else outPath
      )
      inputs;
  };

  nur = inputs.nur.overlays.default;

  additions = final: prev: import ../pkgs { pkgs = final; }
    // {
    vimPlugins = (prev.vimPlugins or { }) // import ../pkgs/vim-plugins { pkgs = final; };
    vscode-extensions = (prev.vscode-extensions or { }) // inputs.vscode-extensions.extensions.${final.system}.vscode-marketplace;
    home-assistant-custom-components = (prev.home-assistant-custom-components or { }) // import ../pkgs/home-assistant-custom-components { pkgs = final; };
    home-assistant-custom-lovelace-modules = (prev.home-assistant-custom-lovelace-modules or { }) // import ../pkgs/home-assistant-custom-lovelace-modules { pkgs = final; };
    home-assistant-custom-themes = import ../pkgs/home-assistant-custom-themes { pkgs = final; };
    nodePackages = (prev.nodePackages or { }) // import ../pkgs/nodePackages { pkgs = final; };
  };

  modifications = final: prev:
    let
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (final) system;
        config.allowUnfree = true;
      };
    in
    {
      # >= 2.26.0 is required for buildbot-nix
      # TODO: remove during upgrade to 25.05
      inherit (pkgsUnstable) nix-eval-jobs;

      # >= 0.7.24 fixes service token expiry
      # reference: https://github.com/al-one/hass-xiaomi-miot/issues/1956
      # TODO: remove during upgrade to 25.05
      home-assistant-custom-components = (prev.home-assistant-custom-components or { }) // {
        xiaomi_miot = prev.home-assistant-custom-components.xiaomi_miot.overrideAttrs (prevAttrs: rec {
          version = "0.7.24";
          name = "python3.12-${prevAttrs.owner}-${prevAttrs.domain}-${version}";
          src = prevAttrs.src.override {
            rev = "v${version}";
            hash = "sha256-DI2e3JBOyBUIUtEYS9ygR3B/XvpB5h6RrBdnNJiwyfY=";
          };
        });
      };
    };
}
