{ pkgs, ... }:
{
  programs.helix = {
    extraPackages = with pkgs; [
      marksman
      nodePackages.bash-language-server
      dockerfile-language-server-nodejs
      python3Packages.python-lsp-server
      nodePackages.typescript-language-server
      lua-language-server
      rust-analyzer
      nil
      lua-language-server
      vhdl-ls
      hyprls
    ];
  };
}
