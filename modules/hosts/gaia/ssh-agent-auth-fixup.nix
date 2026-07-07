{
  flake.modules.nixos."hosts/gaia" = {
    nixpkgs.overlays = [
      (
        # taken from: https://github.com/NixOS/nixpkgs/issues/386392#issuecomment-4896309317
        _final: prev: {
          pam_ssh_agent_auth = prev.pam_ssh_agent_auth.overrideAttrs (old: {
            makeFlags = (old.makeFlags or [ ]) ++ [ "LD=$(CC)" ];
          });
        }
      )
    ];
  };
}
