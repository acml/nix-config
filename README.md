# nix-config

This repository holds both my NixOS configuration (`system/`) as well as my Home
Manager configuration (`home/`), both work together to generate fully
configured, consistent, systems to my liking.

## structure
```
home/
├── combo/            # Meta-configurations (e.g. core, desktop, development)
├── hardware/         # Hardware-specific configuration (e.g. DPI, resolution)
├── machines/         # Configuration for actual hosts (selectively imports combos)
└── modules/          # Composable modules (e.g. neovim, zsh, sway)

system/
├── combo/            # Meta-configurations (e.g. core, desktop, development)
├── hardware/         # Hardware-specific configuration (e.g. kernel modules, peripherals)
├── machines/         # Configuration for actual hosts (selectively imports combos)
└── modules/          # Composable modules (e.g. bumblebee, sudo, sway, xserver)

share/
├── patches/          # Patches for broken software
├── pkgs/             # Personal packages
└── secrets/          # Secrets (API keys)

misc/
├── config.nix        # Example NixOS user configuration
├── configuration.nix # Example NixOS configuration
├── home.nix          # Example home-manager configuration
└── hostnames         # List of hostnames to use
```

## usage
### set up
### everyday


## issues
* my wallpapers are maintained ad-hoc
* no ssh configuration (`.ssh/config`)
* zsh plugins must be manually updates
* sway configuration is done in plaintext
* dunst is not configured sanely
