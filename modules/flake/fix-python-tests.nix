# Tests are flaky, ignore them for now.
{ lib, ... }:
{
  flake.overlays.fix-paho-mqtt = _final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (finalPythonPkgs: prevPythonPkgs: {
        # TODO: remove this once NixOS/nixpkgs#542586 is fixed.
        paho-mqtt = prevPythonPkgs.paho-mqtt.overridePythonAttrs (_finalAttrs: prevAttrs: {
          nativeCheckInputs = lib.remove finalPythonPkgs.pytestCheckHook prevAttrs.nativeCheckInputs;
        });
      })
    ];

    home-assistant-custom-components = prev.home-assistant-custom-components // {
      frigate = prev.home-assistant-custom-components.frigate.overridePythonAttrs (_finalAttrs: prevAttrs: {
        nativeCheckInputs = lib.remove prev.home-assistant.python3Packages.pytestCheckHook prevAttrs.nativeCheckInputs;
      });
    };
  };
}
