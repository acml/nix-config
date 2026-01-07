{ pkgs, ... }:
{
  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      package = pkgs.openssh_gssapi;
      matchBlocks."*" = {
        controlMaster = "auto";
        controlPath = "~/.ssh/ssh-%r@%h:%p";
        controlPersist = "30m";
        forwardAgent = false;
        forwardX11 = false;
        forwardX11Trusted = false;
        hashKnownHosts = true;
        serverAliveCountMax = 5;
        serverAliveInterval = 60;
      };
      extraConfig = "Include config.d/*";
    };
  };
}
