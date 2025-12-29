{ pkgs, inputs, mkHyprlandPlugin, ... }:
let
  inherit (pkgs) lib hyprland cmake unstableGitUpdater;
in

mkHyprlandPlugin hyprland {
  pluginName = "hyprscroller";
  version = inputs.hyprscroller-src.shortRev;

  src = pkgs.inputs.hyprscroller-src;

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv hyprscroller.so $out/lib/libhyprscroller.so

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://github.com/dawsers/hyprscroller";
    description = "Hyprland layout plugin providing a scrolling layout like PaperWM";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
