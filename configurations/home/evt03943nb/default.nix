# Home-manager configuration for evt03943nb
{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake) self;
in
{
  imports = [
    # Internal modules via flake outputs
    self.homeModules.default
    self.homeModules.standalone
    self.homeModules.terminfo-hack
  ];

  # Home settings
  home = {
    username = "ahmet";
    homeDirectory = "/home/ahmet";
    uid = 1000;
    packages = with pkgs; [
      git-dt
      nixVersions.latest
      samba
      xorg.setxkbmap
    ];
  };

  programs = {
    bash = {
      bashrcExtra = ''
        if [ -f /etc/bashrc ]; then
          . /etc/bashrc
        fi
      '';
      profileExtra = ''
        if [ -f /etc/profile ]; then
          . /etc/profile
        fi
      '';
    };
    docker-cli = {
      enable = true;
      settings = {
        "detachKeys" = "ctrl-z,z";
      };
    };
    git.settings.user.email = lib.mkForce "ahmet.ozgezer@siemens.com";
    zsh.initContent = lib.mkOrder 0 ''
      if [[ "$ZSH_VERSION" != "${config.programs.zsh.package.version}" ]]; then
        exec "${config.programs.zsh.package}/bin/zsh"
      fi
    '';
  };
}
