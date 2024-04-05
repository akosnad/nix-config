{ pkgs, scheme, ... }:
let c = scheme.palette;
in pkgs.writeText "eww.css" /* css */ ''
/*
 * {
 all: unset; //Unsets everything so you can style everything from scratch
 }
 */

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
''
