# nix-config ![CI](https://github.com/lovesegfault/nix-config/workflows/CI/badge.svg)

This repository holds my NixOS configuration. It is fully reproducible
(utilizing [niv]) and position-independent, meaning there is no moving around of
`configuration.nix`.

Deployment is done using [`nixus`](https://github.com/Infinisil/nixus), see
[usage](#usage).

For the configurations' entry points see the individual [systems], as well as
[default.nix]. For adding users or overlays see [users](#users),
[overlays](#overlays), respectively.

## structure

```
.
├── core         # Baseline configurations applicable to all machines
├── default.nix  # Nixus deployment configuration
├── dev          # Developer tooling configuration
├── hardware     # Hardware-specific configuration
├── hostnames    # List of hostnames to use
├── nix          # Nix sources managed with niv
├── overlays     # Nixpkgs overlays
├── secrets      # Secrets (API keys, etc)
├── sway         # Sway configuration for the desktop
├── systems      # Machine (host) definitions
└── users        # Per-user configurations
```

## usage

### syncing sources

```shell
niv update
```

### deploying

To deploy all hosts you can use either `nix-build | bash` or, if within
`nix-shell`, the `deploy` script.

Similarly, to deploy a specific host `nix-build -A myHost | bash` or `deploy
myHost` both work.

### adding users

```shell
cp users/template.nix users/myUser.nix
sed -i s/template/myUser/g users/myUser.nix
# You may want to add your openssh key
vim users/myUser.nix
# You may want to add youself to a system
vim systems/mySystem.nix
```

### adding overlays

Overlays should be added as individual nix files to ./overlays with format

```nix
self: super: {
    hello = (super.hello.overrideAttrs (oldAttrs: { doCheck = false; }));
}
```

For more examples see ./overlays.

Overlays **are not** automatically discovered and applied, and must be manually
added to the relevant configuration file.

## issues

* my wallpapers are maintained ad-hoc
* no ssh configuration (`.ssh/config`)
* zsh plugins must be manually updated

[niv]: https://github.com/nmattia/niv
[systems]: https://github.com/lovesegfault/nix-config/blob/master/systems
[default.nix]: https://github.com/lovesegfault/nix-config/blob/master/default.nix
