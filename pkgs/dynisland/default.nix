{ pkgs }: pkgs.rustPlatform.buildRustPackage rec {
  pname = "dynisland";
  version = "0.1.3";

  src = pkgs.fetchFromGitHub {
    owner = "cr3eperall";
    repo = pname;
    rev = "refs/tags/${version}";
    sha256 = "sha256-HqwykR6BXxtYSxNUYdegmjCwSVTW29pqP7qLWbcqLeg=";
    fetchSubmodules = true;
  };

  cargoSha256 = "sha256-p67h67fRNcfiQyhCUY5Y11xTTqQbl0Ngx1EhYfaSJmw=";

  buildFeatures = [ "completions" ];

  buildInputs = with pkgs; [
    dbus
    openssl
    gtk4
    gtk4-layer-shell
  ];

  nativeBuildInputs = with pkgs; [
    glib
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    pkg-config
    wrapGAppsHook4
    installShellFiles
  ];

  postInstall = ''
    installShellCompletion --cmd dynisland \
      --bash ./target/dynisland.bash \
      --fish ./target/dynisland.fish \
      --zsh ./target/_dynisland
  '';

  meta = with pkgs.lib; {
    description = "A dynamic and extensible GTK4 bar for compositors implementing wlr-layer-shell, written in Rust.";
    mainProgram = pname;
    homepage = "https://github.com/cr3eperall/dynisland";
    license = with licenses; [ mit ];
  };
}
