{ home-manager, lib, nix-index-database, pkgs, ... }: {
  imports = [
    home-manager.darwinModules.home-manager
    nix-index-database.darwinModules.nix-index
  ];

  environment = {
    postBuild = ''
      ln -sv ${pkgs.path} $out/nixpkgs
      ln -sv ${../nix/overlays} $out/overlays
    '';
    shells = with pkgs; [ fish zsh ];
    shellAliases.tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
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
    systemPath = lib.mkBefore [
      "/opt/homebrew/bin"
    ];
    variables = {
      SHELL = lib.getExe pkgs.fish;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    taps = [ "homebrew/core" ];
    brews = [ "git" "mas" ];
    masApps = {
      "Tailscale" = 1475387142;
    };
  };

  nix = {
    gc.automatic = true;
    settings.trusted-users = [ "root" "bemeurer" ];
  };

  programs.fish.loginShellInit = "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin";

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
    stateVersion = 4;
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleTemperatureUnit = "Celsius";
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      finder.QuitMenuItem = true;
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        mineffect = "scale";
        orientation = "left";
        show-recents = false;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}