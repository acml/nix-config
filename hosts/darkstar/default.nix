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

        if command -v tmux &> /dev/null && [[ $- == *i* ]] && [[ ! "$TERM" =~ xterm-kitty ]] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$INSIDE_EMACS" ] && [ -z "$VIMRUNTIME" ] && [ -z "$TMUX" ]; then
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

        # Temporary fix for WSLg keyboard layout (only change the first line)
        KEYMAP_LAYOUT=us
        KEYMAP_VARIANT=colemak
        if [ ! -f /mnt/wsl/state-wslg-config-initialized ]; then
          read -r -d "" GWSL_SYSTEM_CONFIG_COMMANDS <<EOF
            KEYMAP_LAYOUT=\$(grep -r '^keymap_layout=.*\$' /home/wslg/.config/weston.ini); if [ -z \$KEYMAP_LAYOUT ]; then sed -i '$ a\[keyboard]\nkeymap_layout=''${KEYMAP_LAYOUT}\nkeymap_variant=''${KEYMAP_VARIANT}\n' /home/wslg/.config/weston.ini; pkill -HUP weston; touch /mnt/wsl/state-wslg-config-initialized; fi
        EOF
          wsl.exe -d $WSL_DISTRO_NAME --system ''${GWSL_SYSTEM_CONFIG_COMMANDS} >/dev/null 2>&1 || wsl.exe -d $WSL_DISTRO_NAME --system ''${GWSL_SYSTEM_CONFIG_COMMANDS}
        fi
      '';
      sessionVariables = {
        COLORTERM = "truecolor";
      };
    };
    git.userEmail = lib.mkForce "ozgezer@gmail.com";
    zsh = {
      initExtraBeforeCompInit = ''
        fpath+=("$HOME/.zsh/completion")
      '';
    };
  };
}
