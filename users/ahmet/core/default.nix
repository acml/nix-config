{ base16-schemes, hostType, impermanence, lib, nix-index-database, pkgs, nixvim, catppuccin, stylix, ... }: {
  imports = [
    impermanence.nixosModules.home-manager.impermanence
    nix-index-database.hmModules.nix-index
    nixvim.homeManagerModules.nixvim
    catppuccin.homeManagerModules.catppuccin
    stylix.homeManagerModules.stylix

    ./bash.nix
    ./fish.nix
    ./git.nix
    ./htop.nix
    ./emacs
    ./nixvim
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./xdg.nix
    ./zsh.nix
  ];

  # XXX: Manually enabled in the graphic module
  dconf.enable = false;

  home = {
    username = "ahmet";
    stateVersion = "23.05";
    packages = with pkgs; [
      eza
      fd
      fzf
      kalker
      neofetch
      nix-closure-size
      nix-output-monitor
      ripgrep
      rsync
      truecolor-check
    ] ++ (lib.optional (hostType != "darwin") mosh);
    shellAliases = {
      cat = "bat";
      cls = "clear";
      l = "ls";
      la = "ls --all";
      ls = "eza --binary --header --long --icons";
      man = "batman";
    };
  };

  programs = {
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        enter_accept = true;
        show_help = false;
        update_check = false;
        workspaces = true;
      };
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
    };
    btop.enable = true;
    gpg.enable = true;
    nix-index.enable = true;
    yazi = {
      enable = true;
      settings = {
        manager = {
          ratio = [ 1 2 5 ];
        };
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = false;
      options = [ "--cmd cd" ];
    };
    bash.initExtra =
      lib.mkOrder 2000 # sh
        ''
          eval "$(${lib.getExe pkgs.zoxide} init bash --cmd cd)"
        '';
  };

  stylix = {
    enable = true;
    base16Scheme = "${base16-schemes}/catppuccin-mocha.yaml";
    # XXX: We fetchurl from the repo because flakes don't support git-lfs assets
    image = pkgs.fetchurl {
      url = "https://media.githubusercontent.com/media/lovesegfault/nix-config/bda48ceaf8112a8b3a50da782bf2e65a2b5c4708/users/bemeurer/assets/walls/plants-00.jpg";
      hash = "sha256-n8EQgzKEOIG6Qq7og7CNqMMFliWM5vfi2zNILdpmUfI=";
    };
    targets = {
      gnome.enable = hostType == "nixos";
      gtk.enable = hostType == "nixos";
      kde.enable = lib.mkDefault false;
      xfce.enable = lib.mkDefault false;
      nixvim.enable = lib.mkDefault false;
      bat.enable = lib.mkDefault false;
      btop.enable = lib.mkDefault false;
      emacs.enable = lib.mkDefault false;
      kitty.enable = lib.mkDefault false;
      yazi.enable = lib.mkDefault false;
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha"; # "latte" "frappe" "macchiato" "mocha"
    # accent = "rosewater"; # "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach" "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow"
    cursors.enable = false;
  };

  systemd.user.startServices = "sd-switch";

  xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
}
