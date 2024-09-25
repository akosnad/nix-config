{ pkgs }: pkgs.rustPlatform.buildRustPackage rec {
  pname = "dynisland";
  version = "0.1.3";

  src = pkgs.fetchFromGitHub {
    owner = "cr3eperall";
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-HqwykR6BXxtYSxNUYdegmjCwSVTW29pqP7qLWbcqLeg=";
  };

  cargoSha256 = "sha256-p67h67fRNcfiQyhCUY5Y11xTTqQbl0Ngx1EhYfaSJmw=";

  buildNoDefaultFeatures = true;
  buildFeatures = [ ];

  nativeBuildInputs = with pkgs; [
    pkg-config
    makeWrapper
  ];

  buildInputs = with pkgs; [
    openssl
    glib
    cairo
    dbus
    gdk-pixbuf
    gtk4
    gtk4-layer-shell
  ];

  meta = with pkgs.lib; {
    description = "A dynamic and extensible GTK4 bar for compositors implementing wlr-layer-shell, written in Rust.";
    mainProgram = pname;
    homepage = "https://github.com/cr3eperall/dynisland";
    license = with licenses; [ mit ];
  };
}
