{ config, ... }:
let
  c = config.colorScheme.palette;
in
{
  programs.helix = {
    settings.theme = "base16";
    themes.base16 = {
      # taken from: https://github.com/tinted-theming/base16-helix/blob/97e09cf8a1965293592f4a14ff4908f560488594/templates/default.mustache
      "attributes" = "#${c.base09}";
      "comment" = { fg = "#${c.base03}"; modifiers = [ "italic" ]; };
      "constant" = "#${c.base09}";
      "constant.character.escape" = "#${c.base0C}";
      "constant.numeric" = "#${c.base09}";
      "constructor" = "#${c.base0D}";
      "debug" = "#${c.base03}";
      "diagnostic" = { modifiers = [ "underlined" ]; };
      "diff.delta" = "#${c.base09}";
      "diff.minus" = "#${c.base08}";
      "diff.plus" = "#${c.base0B}";
      "error" = "#${c.base08}";
      "function" = "#${c.base0D}";
      "hint" = "#${c.base03}";
      "info" = "#${c.base0D}";
      "keyword" = "#${c.base0E}";
      "label" = "#${c.base0E}";
      "namespace" = "#${c.base0E}";
      "operator" = "#${c.base05}";
      "special" = "#${c.base0D}";
      "string" = "#${c.base0B}";
      "type" = "#${c.base0A}";
      "variable" = "#${c.base08}";
      "variable.other.member" = "#${c.base0B}";
      "warning" = "#${c.base09}";
      "markup.bold" = { fg = "#${c.base0A}"; modifiers = [ "bold" ]; };
      "markup.heading.1" = { fg = "#${c.base0D}"; modifiers = [ "bold" ]; };
      "markup.heading.2" = { fg = "#${c.base08}"; modifiers = [ "bold" ]; };
      "markup.heading.3" = { fg = "#${c.base09}"; modifiers = [ "bold" ]; };
      "markup.heading.4" = { fg = "#${c.base0A}"; modifiers = [ "bold" ]; };
      "markup.heading.5" = { fg = "#${c.base0B}"; modifiers = [ "bold" ]; };
      "markup.heading.6" = { fg = "#${c.base0C}"; modifiers = [ "bold" ]; };
      "markup.italic" = { fg = "#${c.base0E}"; modifiers = [ "italic" ]; };
      "markup.link.text" = "#${c.base08}";
      "markup.link.url" = { fg = "#${c.base09}"; modifiers = [ "underlined" ]; };
      "markup.list" = "#${c.base08}";
      "markup.quote" = "#${c.base0C}";
      "markup.raw" = "#${c.base0B}";
      "markup.strikethrough" = { modifiers = [ "crossed_out" ]; };
      "diagnostic.hint" = { underline = { style = "curl"; }; };
      "diagnostic.info" = { underline = { style = "curl"; }; };
      "diagnostic.warning" = { underline = { style = "curl"; }; };
      "diagnostic.error" = { underline = { style = "curl"; }; };
      "ui.bufferline.active" = { fg = "#${c.base00}"; bg = "#${c.base03}"; modifiers = [ "bold" ]; };
      "ui.bufferline" = { fg = "#${c.base04}"; bg = "#${c.base00}"; };
      "ui.cursor" = { fg = "#${c.base05}"; modifiers = [ "reversed" ]; };
      "ui.cursor.insert" = { fg = "#${c.base05}"; modifiers = [ "reversed" ]; };
      "ui.cursorline.primary" = { fg = "#${c.base05}"; bg = "#${c.base01}"; };
      "ui.cursor.match" = { fg = "#${c.base05}"; bg = "#${c.base02}"; modifiers = [ "bold" ]; };
      "ui.cursor.select" = { fg = "#${c.base05}"; modifiers = [ "reversed" ]; };
      "ui.gutter" = { bg = "#${c.base00}"; };
      "ui.help" = { fg = "#${c.base06}"; bg = "#${c.base01}"; };
      "ui.linenr" = { fg = "#${c.base03}"; bg = "#${c.base00}"; };
      "ui.linenr.selected" = { fg = "#${c.base04}"; bg = "#${c.base01}"; modifiers = [ "bold" ]; };
      "ui.menu" = { fg = "#${c.base05}"; bg = "#${c.base01}"; };
      "ui.menu.scroll" = { fg = "#${c.base03}"; bg = "#${c.base01}"; };
      "ui.menu.selected" = { fg = "#${c.base01}"; bg = "#${c.base04}"; };
      "ui.popup" = { bg = "#${c.base01}"; };
      "ui.selection" = { bg = "#${c.base02}"; };
      "ui.selection.primary" = { bg = "#${c.base02}"; };
      "ui.statusline" = { fg = "#${c.base04}"; bg = "#${c.base01}"; };
      "ui.statusline.inactive" = { bg = "#${c.base01}"; fg = "#${c.base03}"; };
      "ui.statusline.insert" = { fg = "#${c.base00}"; bg = "#${c.base0B}"; };
      "ui.statusline.normal" = { fg = "#${c.base00}"; bg = "#${c.base03}"; };
      "ui.statusline.select" = { fg = "#${c.base00}"; bg = "#${c.base0F}"; };
      "ui.text" = "#${c.base05}";
      "ui.text.directory" = "#${c.base0D}";
      "ui.text.focus" = "#${c.base05}";
      "ui.virtual.indent-guide" = { fg = "#${c.base03}"; };
      "ui.virtual.inlay-hint" = { fg = "#${c.base03}"; };
      "ui.virtual.ruler" = { bg = "#${c.base01}"; };
      "ui.virtual.jump-label" = { fg = "#${c.base0A}"; modifiers = [ "bold" ]; };
      "ui.window" = { bg = "#${c.base01}"; };
    };
  };
}
