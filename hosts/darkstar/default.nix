{ lib, pkgs, ... }: {
  imports = [ ../../users/ahmet ];

  home = {
    uid = 1000;
    packages = with pkgs; [
      xorg.setxkbmap
      # rustup 
    ];
  };

  programs = {
    bash = {
      bashrcExtra = ''
        if [ -f /etc/bashrc ]; then
        . /etc/bashrc
        fi

        if command -v tmux &> /dev/null && [[ $- == *i* ]] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$INSIDE_EMACS" ] && [ -z "$TMUX" ]; then
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
        export PATH="$PATH:$HOME/.toolbox/bin:/apollo/env/bt-rust/bin"
      '';
    };
    fish.shellInit = ''
      fish_add_path --append --path "$HOME/.toolbox/bin"
      fish_add_path --append --path "/apollo/env/bt-rust/bin"
    '';
    git.userEmail = lib.mkForce "ozgezer@gmail.com";
    zsh = {
      initExtraBeforeCompInit = ''
        fpath+=("$HOME/.zsh/completion")
      '';
      initExtra = ''
        export PATH="$PATH:$HOME/.toolbox/bin:/apollo/env/bt-rust/bin"
      '';
    };
  };
}
