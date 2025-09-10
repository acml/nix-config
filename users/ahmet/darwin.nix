{ pkgs, ... }:
{
  home-manager.users.ahmet =
    { lib, ... }:
    {
      imports = [
        ./graphical
        # ./trusted
      ];
      # c.f. https://github.com/danth/stylix/issues/865
      nixpkgs.overlays = lib.mkForce null;
      # programs.git.extraConfig.gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

  system.primaryUser = "ahmet";

  users.users.ahmet = {
    createHome = true;
    description = "Ahmet Cemal Özgezer";
    home = "/Users/ahmet";
    isHidden = false;
    shell = pkgs.zsh;
  };
}
