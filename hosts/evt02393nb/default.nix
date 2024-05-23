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

        if command -v tmux &> /dev/null && [[ $- == *i* ]] && [[ ! "$TERM" =~ xterm-kitty ]] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$INSIDE_EMACS" ] && [ -z "$TMUX" ]; then
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
            KEYMAP_LAYOUT=\`grep -r '^keymap_layout=.*\$' /home/wslg/.config/weston.ini\`;if [ -z \$KEYMAP_LAYOUT ]; then sed -i '$ a\[keyboard]\nkeymap_layout=`echo ''${KEYMAP_LAYOUT}`\nkeymap_variant=`echo ''${KEYMAP_VARIANT}`\n' /home/wslg/.config/weston.ini;pkill -HUP weston;touch /mnt/wsl/state-wslg-config-initialized;fi
        EOF
          wsl.exe -d $WSL_DISTRO_NAME --system ''${GWSL_SYSTEM_CONFIG_COMMANDS}
        fi
      '';
    };
    git.userEmail = lib.mkForce "ahmet.ozgezer@siemens.com";
  };
}
