{ withSystem, config, ... }:
{
  herculesCI = herculesCI: {
    onPush.default.outputs.effects = {
      pin-caches = withSystem config.defaultEffectSystem (
        { pkgs, hci-effects, ... }:
        hci-effects.runIf (herculesCI.config.repo.branch == "main" || herculesCI.config.repo.branch == "ci-test") (
          hci-effects.mkEffect {
            effectScript = ''
              echo "${builtins.toJSON { inherit (herculesCI.config.repo) branch tag rev; }}"
              ${pkgs.hello}/bin/hello
            '';
          }
        )
      );
    };
  };
}
