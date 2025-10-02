<div align="center">
  <h1>akosnad/nix-config</h1>
  <h3>Nix config for everything possible™</h3>
</div>

<div align="center">
  <img src="assets/all.jpg" alt="It's all nix code??" width=512/>
</div>


This repo contains declarative configuration for:
- my [NixOS](https://nixos.org/) computers, under `hosts/`
- [Home Manager](https://github.com/nix-community/home-manager) based rice for desktop machines, under `home/`
- devices on my home network - DHCP, DNS, etc., in `devices.nix`
- IoT smart home devices firmware using [ESPHome](https://esphome.io), under `esphome-hosts/`
- some things I packaged with nix that the above uses, under `pkgs/`
- custom NixOS/flake-parts modules that enable the whole thing to exist, under `modules/`

> [!NOTE]
> This hunk of code by any means is not made for consumption by others as it is too specific and tailored exatly to my own taste and use-cases.
> However, feel free to get inspired or object to anything related to it. I do not take responsibility in any harm
> caused to your sanity while reading through all this. If you want me to license it for some reason, feel free to reach out.

*If you really want to understand what this is about, check out the [AI generated documentation on DeepWiki](https://deepwiki.com/akosnad/nix-config).
It did a pretty good job of understanding the repo. Some things are overly verbose and repetitive, but only a couple of small details were left out, like how are ESPHome devices updated.*

## Device topology

Here is a diagram that explains what this mess is about better than I did above.

[![Topology diagram](https://topology-diagram.akos-23c.workers.dev/main.svg)](https://topology-diagram.akos-23c.workers.dev/main.svg)

## Network topology

[![Topology diagram](https://topology-diagram.akos-23c.workers.dev/network.svg)](https://topology-diagram.akos-23c.workers.dev/network.svg)
