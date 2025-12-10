# Darwin system user configuration for ahmet
{ config, pkgs, ... }:
{
  # Link home-manager user to Darwin user
  home-manager.users.ahmet.home = {
    username = "ahmet";
    inherit (config.users.users.ahmet) uid;
  };

  users.users.ahmet = {
    createHome = true;
    description = "Ahmet Cemal Özgezer";
    home = "/Users/ahmet";
    isHidden = false;
    shell = pkgs.zsh;
  };
}
