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

        if command -v tmux &> /dev/null && [[ $- == *i* ]] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
          exec tmux new-session -A -s main >/dev/null 2>&1
        fi
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
