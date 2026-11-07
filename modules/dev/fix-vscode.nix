{ lib, ... }:
{
  flake.overlays.fix-vscode = _final: prev: {
    vscode = prev.vscode.overrideAttrs (_: prevAttrs: {
      # workaround for `rg` not existing at the time
      # of `rm` running. this ignores the error, just
      # before linking in `pkgs.ripgrep` in postPatch
      #
      # TODO: remove after upstream fixes
      postPatch = lib.replaceStrings
        [ "rm resources/app/node_modules/@vscode/ripgrep/bin/rg" ]
        [ "rm -f resources/app/node_modules/@vscode/ripgrep/bin/rg\nmkdir -p resources/app/node_modules/@vscode/ripgrep/bin" ]
        prevAttrs.postPatch;
    });
  };
}
