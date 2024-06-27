{ pkgs }: {
  vim-transparent = pkgs.callPackage ./vim-transparent.nix { };
  prettier-nvim = pkgs.callPackage ./prettier-nvim.nix { };
}
