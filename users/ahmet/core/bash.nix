{ config, ... }:
{
  programs.bash = {
    enable = true;
    historyControl = [
      "erasedups"
      "ignorespace"
    ];
    historyFile = "${config.xdg.dataHome}/bash/history";
    historyFileSize = 30000;
    historySize = 10000;
    bashrcExtra = ''
      CONST_SSH_SOCK="$HOME/.ssh/ssh-auth-sock"
      if [ ! -z ''${SSH_AUTH_SOCK+x} ] && [ "$SSH_AUTH_SOCK" != "$CONST_SSH_SOCK" ]; then
        rm -f "$CONST_SSH_SOCK"
        ln -sf "$SSH_AUTH_SOCK" "$CONST_SSH_SOCK"
        export SSH_AUTH_SOCK="$CONST_SSH_SOCK"
      fi

      # if command -v tmux &> /dev/null && [[ $- == *i* ]] && [[ ! "$TERM" =~ xterm-kitty ]] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$INSIDE_EMACS" ] && [ -z "$MYVIMRC" ] && [ -z "$VIMRUNTIME" ] && [ -z "$TMUX" ]; then
      #   exec tmux new-session -A -s main >/dev/null 2>&1
      # fi
    '';
    profileExtra = ''
      # Temporary fix for WSLg keyboard layout (only change the first line)
      if [[ -f /proc/version ]] && grep -i Microsoft /proc/version >/dev/null 2>&1; then
        KEYMAP_LAYOUT=us
        KEYMAP_VARIANT=colemak
        if [ ! -f /mnt/wsl/state-wslg-config-initialized ]; then
          read -r -d "" GWSL_SYSTEM_CONFIG_COMMANDS <<EOF
            KEYMAP_LAYOUT=\$(grep -r '^keymap_layout=.*\$' /home/wslg/.config/weston.ini); if [ -z \$KEYMAP_LAYOUT ]; then sed -i '$ a\[keyboard]\nkeymap_layout=''${KEYMAP_LAYOUT}\nkeymap_variant=''${KEYMAP_VARIANT}\n' /home/wslg/.config/weston.ini; pkill -HUP weston; touch /mnt/wsl/state-wslg-config-initialized; fi
      EOF
          wsl.exe -d $WSL_DISTRO_NAME --system ''${GWSL_SYSTEM_CONFIG_COMMANDS} >/dev/null 2>&1 || wsl.exe -d $WSL_DISTRO_NAME --system ''${GWSL_SYSTEM_CONFIG_COMMANDS}
        fi
      fi

      vterm_printf() {
          if [ -n "$TMUX" ] && ([ "''${TERM%%-*}" = "tmux" ] || [ "''${TERM%%-*}" = "screen" ]); then
              # Tell tmux to pass the escape sequences through
              printf "\ePtmux;\e\e]%s\007\e\\" "$1"
          elif [ "''${TERM%%-*}" = "screen" ]; then
              # GNU screen (screen, screen-256color, screen-256color-bce)
              printf "\eP\e]%s\007\e\\" "$1"
          else
              printf "\e]%s\e\\" "$1"
          fi
      }

      if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
          function clear() {
              vterm_printf "51;Evterm-clear-scrollback";
              tput clear;
          }
      fi

      vterm_prompt_end(){
          vterm_printf "51;A$USER@$HOST:$PWD"
      }
      PS1=$PS1'\[$(vterm_prompt_end)\]'

      vterm_cmd() {
          local vterm_elisp
          vterm_elisp=""
          while [ $# -gt 0 ]; do
              vterm_elisp="$vterm_elisp""$(printf '"%s" ' "$(printf "%s" "$1" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
              shift
          done
          vterm_printf "51;E$vterm_elisp"
      }
    '';
  };
}
