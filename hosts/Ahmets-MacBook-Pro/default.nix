{ lib, ... }:
{
  imports = [
    ../../core

    ../../graphical

    ../../users/ahmet
  ];

  environment.variables.JAVA_HOME = "$(/usr/libexec/java_home)";

  homebrew = {
    enable = lib.mkForce true;
  };

  home-manager.users.ahmet =
    { config, ... }:
    {
      home.sessionPath = [
        "${config.home.homeDirectory}/.toolbox/bin"
        "${config.home.homeDirectory}/.local/bin"
      ];
    };

  nix = {
    enable = false;
    gc.automatic = false;
    # linux-builder.enable = true;
    settings = {
      #  system-features = [ "big-parallel" "gccarch-armv8-a" ];
      trusted-users = [ "ahmet" ];
    };
  };

  users.users.ahmet = {
    uid = 501;
    gid = 20;
  };

  ids.gids.nixbld = 350;
}
