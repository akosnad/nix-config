{ pkgs, ... }:
# we do a bit of IFD to help with GPG key rotation;
# ./gpg.pub should the single source of truth for any config in this repo
pkgs.stdenvNoCC.mkDerivation {
  name = "gpg-key";
  src = ./gpg.pub;
  dontUnpack = true;
  preferLocalBuild = true;
  allowSubstitutes = false;
  nativeBuildInputs = with pkgs; [ gnupg ];
  buildPhase = ''
    mkdir -p $out
    export GNUPGHOME="$(mktemp -d)"
    gpg --import $src

    gpg --with-colons --with-keygrip --list-keys \
      | awk -F: '
          /^sub|^ssb/ { cap=$12; kid=$5 }
          /^grp/ && (cap ~ /[Aa]/) { print $10; cap=""; }' \
      | tr -d '\n' \
      > $out/keygrip

    KEYID="$(gpg --with-colons --list-keys \
      | awk -F: '/^pub/ { pub=1 } /^fpr/ && pub { print $10; pub=0 }' \
      | tr -d '\n' \
    )"
    echo -n "$KEYID" > $out/fingerprint

    gpg --export-ssh-key "$KEYID" > $out/ssh.pub
  '';
}
