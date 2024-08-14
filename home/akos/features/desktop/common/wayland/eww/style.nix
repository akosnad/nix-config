{ pkgs, scheme, ... }:
let c = scheme.palette;
in pkgs.writeText "eww.scss" /* css */ ''
  /*
   * {
   all: unset; //Unsets everything so you can style everything from scratch
   }
   */

  window {
    background-color: rgba(0, 0, 0, 0);
  }

  .bar {
    background-color: rgba(#${c.base00}, 0.9);
  }

  .sidestuff {
    margin-right: 1em;
  }

  .centerstuff {
  }

  .metric scale trough slider {
    background-image: none;
    background-color: rgba(0, 0, 0, 0);
  }
  .metric scale trough highlight:disabled {
    background-color: #${c.base02};
  }
  .metric scale trough {
    border-radius: 50px;
    min-height: 3px;
    min-width: 35px;
    margin-left: 5px;
    margin-right: 5px;
  }

  .workspace-entry {
    padding-left: 5px;
    padding-right: 5px;
  }

  .workspace-entry.empty {
    color: #${c.base03};
  }
  .workspace-entry.current {
    background-color: #${c.base02};
  }

  .sidestuff .kb-layout {
    padding-right: 1em;
  }

  .stuff {
    all: unset;
  }

  .gap {
    padding-left: 1em;
  }

  .securitykey {
    background-color: #${c.base0A};
    color: #${c.base00};
    padding-left: 0.5em;
    padding-right: 1em;
    margin: 0;
  };

  .securitykey > label {
    padding: 0;
    margin: 0;
  };
''
