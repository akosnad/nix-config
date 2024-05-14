{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jetbrains.idea-ultimate
    jetbrains.jdk
    github-copilot-intellij-agent
  ];
}
