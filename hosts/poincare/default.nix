{ config, lib, pkgs, ... }:
let
  dummyConfig = pkgs.writeText "darwin-configuration.nix" ''
    assert builtins.trace "This is a dummy config, use the nix-config flake!" false;
    { }
  '';
in
{
  environment = {
    pathsToLink = [
      "/share/fish"
      "/share/zsh"
    ];
    postBuild = ''
      ln -sv ${pkgs.path} $out/nixpkgs
      ln -sv ${../../nix/overlays} $out/overlays
    '';
    shells = with pkgs; [ fish ];
    systemPackages = with pkgs; [
      coreutils
      findutils
      gawk
      git
      gnugrep
      gnused
      gnutar
      gnutls
      ncurses
      openssh_gssapi
    ];
    variables = {
      JAVA_HOME = "$(/usr/libexec/java_home)";
      SHELL = lib.getExe pkgs.fish;
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [ (nerdfonts.override { fonts = [ "Hack" ]; }) ];
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    taps = [
      "1password/tap"
      "homebrew/core"
      "homebrew/cask"
    ];
    brews = [
      "git"
      "mas"
    ];
    casks = [
      { name = "1password"; greedy = true; }
      { name = "1password-cli"; greedy = true; }
      { name = "aldente"; greedy = true; }
      { name = "alt-tab"; greedy = true; }
      { name = "amethyst"; greedy = true; }
      { name = "appcleaner"; greedy = true; }
      { name = "balenaetcher"; greedy = true; }
      { name = "bartender"; greedy = true; }
      { name = "daisydisk"; greedy = true; }
      { name = "dash"; greedy = true; }
      { name = "detexify"; greedy = true; }
      { name = "discord"; greedy = true; }
      { name = "element"; greedy = true; }
      { name = "firefox"; greedy = true; }
      { name = "google-chrome"; greedy = true; }
      { name = "iterm2"; greedy = true; }
      { name = "kitty"; greedy = true; }
      { name = "ksdiff"; greedy = true; }
      { name = "lunar"; greedy = true; }
      { name = "macupdater"; greedy = true; }
      { name = "mullvadvpn"; greedy = true; }
      { name = "nextcloud"; greedy = true; }
      { name = "parallels"; greedy = true; }
      { name = "plexamp"; greedy = true; }
      { name = "quip"; greedy = true; }
      { name = "raycast"; greedy = true; }
      { name = "roon"; greedy = true; }
      { name = "shottr"; greedy = true; }
      { name = "signal"; greedy = true; }
      { name = "spotify"; greedy = true; }
      { name = "stats"; greedy = true; }
      { name = "tidal"; greedy = true; }
      { name = "topnotch"; greedy = true; }
      { name = "visual-studio-code"; greedy = true; }
      { name = "zoom"; greedy = true; }
      { name = "zulip"; greedy = true; }
    ];
    masApps = {
      "Amphetamine" = 937984704;
      "Deliveries" = 290986013;
      "Geekbench 5" = 1478447657;
      "Kaleidoscope" = 1575557335;
      "Keynote" = 409183694;
      "LanguageTool" = 1534275760;
      "Noizio" = 928871589;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Soulver 3" = 1508732804;
      "Speedtest" = 1153157709;
      "Tailscale" = 1475387142;
      "The Clock" = 488764545;
      "The Unarchiver" = 425424353;
      "Xcode" = 497799835;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };

  home-manager.users.bemeurer = { config, ... }: {
    imports = [
      ../../users/bemeurer/core
      ../../users/bemeurer/dev
      ../../users/bemeurer/modules
      ../../users/bemeurer/trusted
    ];
    home = {
      file.".nixpkgs/darwin-configuration.nix".source = dummyConfig;

      sessionPath = [
        "${config.home.homeDirectory}/.toolbox/bin"
        "${config.home.homeDirectory}/.local/bin"
        "/opt/homebrew/bin"
      ];

      shellAliases.tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

      uid = 504;
    };
    programs.git = {
      lfs.enable = true;
      extraConfig.gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };

  nix = {
    daemonIOLowPriority = true;
    gc.automatic = true;
    nixPath = [{
      nixpkgs = "/run/current-system/sw/nixpkgs";
      nixpkgs-overlays = "/run/current-system/sw/overlays";
    }];
    settings = {
      accept-flake-config = true;
      # XXX: Causes annoying "cannot link ... to ...: File exists" errors
      auto-optimise-store = false;
      build-users-group = "nixbld";
      builders-use-substitutes = true;
      connect-timeout = 5;
      experimental-features = [ "nix-command" "flakes" "recursive-nix" ];
      http-connections = 0;
      sandbox = false;
      substituters = [
        "https://nix-config.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [ "root" "bemeurer" ];
    };
    extraOptions = ''
      !include tokens.conf
    '';
  };

  programs = {
    fish.enable = true;
    fish.loginShellInit = "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin";
    zsh.enable = true;
  };

  security.pam.enableSudoTouchIdAuth = true;

  services = {
    skhd = {
      enable = true;
      skhdConfig = ''
        cmd - return : kitty -1 -d ~
      '';
    };
    nix-daemon = {
      enable = true;
      logFile = "/var/log/nix-daemon.log";
    };
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleTemperatureUnit = "Celsius";
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      finder.QuitMenuItem = true;
      dock.autohide = true;
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  users.users.bemeurer = {
    uid = 504;
    gid = 20;
    createHome = true;
    description = "Bernardo Meurer";
    home = "/Users/bemeurer";
    isHidden = false;
    shell = pkgs.fish;
  };
}
