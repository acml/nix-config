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
        # controlPersist = "30s";
        # forwardAgent = false;
        # forwardX11 = false;
        # forwardX11Trusted = false;
        # hashKnownHosts = true;
        serverAliveCountMax = 3;
        serverAliveInterval = 30;
      };
      extraConfig = "Include config.d/*";
    };
  };
}
