{
  imports = [
    ../../core

    ../../graphical

    ../../users/ahmet
  ];

  environment.variables.JAVA_HOME = "$(/usr/libexec/java_home)";

  #homebrew.casks = [
  #  { name = "docker"; greedy = true; }
  #];

  home-manager.users.ahmet = { config, ... }: {
    home.sessionPath = [
      "${config.home.homeDirectory}/.toolbox/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];
  };

  nix = {
    gc.automatic = true;
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
}
