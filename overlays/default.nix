{ inputs, ... }: {
  # Alias 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs = builtins.mapAttrs
      (_: flake:
        let
          legacyPackages = ((flake.legacyPackages or { }).${final.system} or { });
          packages = (flake.packages or { }).${final.system} or { };
        in
        if legacyPackages != { } then legacyPackages else packages
      )
      inputs;
  };

  additions = final: prev: import ../pkgs { pkgs = final; }
    // {
    vscode-extensions = (prev.vscode-extensions or { }) // inputs.vscode-extensions.extensions.${final.system}.vscode-marketplace;
  };

  modifications = _final: _prev: { };
}
