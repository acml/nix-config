{ pkgs, ... }: {
  home-manager.users.ahmet = {
    imports = [
      ./graphical
      # ./trusted
    ];
    # programs.git.extraConfig.gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };

  users.users.ahmet = {
    createHome = true;
    description = "Ahmet Cemal Ozgezer";
    home = "/Users/ahmet";
    isHidden = false;
    shell = pkgs.zsh;
  };
}
