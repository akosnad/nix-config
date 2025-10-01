args @ { pkgs, config, lib, ... }:
let

  gpgKeyDerivation = pkgs.callPackage ../../gpg-key.nix args;
  keygrip = builtins.readFile "${gpgKeyDerivation}/keygrip";
  keyFingerprint = builtins.readFile "${gpgKeyDerivation}/fingerprint";
in
{
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableSshSupport = true;
    sshKeys = [ keygrip ];
    pinentry.package = if config.gtk.enable then pkgs.pinentry-gnome3 else pkgs.pinentry-curses;
  };

  home.packages = lib.optional config.gtk.enable pkgs.gcr;

  programs =
    let
      fixGpg = /* bash */ ''
        gpgconf --launch gpg-agent
      '';
    in
    {
      # Start gpg-agent if it's not running or tunneled in
      # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
      # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
      bash.profileExtra = fixGpg;
      fish.loginShellInit = fixGpg;
      zsh.loginExtra = fixGpg;

      gpg = {
        enable = true;
        settings = {
          trust-model = "tofu+pgp";
        };
        scdaemonSettings.disable-ccid = true;
        # publicKeys = [{
        #   source = ../../pgp.asc;
        #   trust = 5;
        # }];
      };

      git.signing = {
        signByDefault = true;
        key = keyFingerprint;
      };
    };

  systemd.user.services = {
    # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
    # So that SSH config does not have to know the UID
    link-gnupg-sockets = {
      Unit = {
        Description = "link gnupg sockets from /run to /home";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
        ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  home.file."${config.home.homeDirectory}/.gnupg/sshcontrol" = lib.mkIf config.programs.gpg.enable {
    force = true;
  };
  home.file."${config.home.homeDirectory}/.gnupg/scdaemon.conf" = lib.mkIf config.programs.gpg.enable {
    force = true;
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [{
    directory = ".gnupg";
    method = "bindfs";
  }];
}
