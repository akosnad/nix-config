{ inputs, ... }:
{
  flake.modules.homeManager.base = {
    imports = [ (inputs.import-tree ./_stylix-modules/hm) ];
  };
}
