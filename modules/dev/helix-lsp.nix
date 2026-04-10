let
  flake.modules.homeManager.helix-lsp =
    { pkgs, ... }:
    {
      programs.helix = {
        extraPackages = with pkgs; [
          marksman
          nodePackages.bash-language-server
          dockerfile-language-server
          python3Packages.python-lsp-server
          nodePackages.typescript-language-server
          lua-language-server
          rust-analyzer
          nixd
          lua-language-server
          vhdl-ls
          hyprls
        ];
      };
    };

  flake.modules.homeManager.dev.imports = [ flake.modules.homeManager.helix-lsp ];
in
{
  inherit flake;
}
