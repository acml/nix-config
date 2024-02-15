{ lib, pkgs, ... }: {
  imports = [ ../../users/ahmet ];

  home = {
    uid = 1000;
    packages = with pkgs; [
      xorg.setxkbmap
    ];
  };

  programs = {
    bash = {
      bashrcExtra = ''
        if [ -f /etc/bashrc ]; then
        . /etc/bashrc
        fi

        # bind to the up key, which depends on terminal mode
        bind -x '"\C-p": __atuin_history --shell-up-key-binding'
        bind -x '"\e[A": __atuin_history --shell-up-key-binding'
        bind -x '"\eOA": __atuin_history --shell-up-key-binding'
      '';
      profileExtra = ''
        if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
          source ~/.nix-profile/etc/profile.d/nix.sh
        fi

        if [ -f /etc/bashrc ]; then
        . /etc/bashrc
        fi
      '';
    };
    git.userEmail = lib.mkForce "ahmet.ozgezer@siemens.com";
  };
}
