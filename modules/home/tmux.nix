{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      lib.optionals stdenv.hostPlatform.isLinux [
        sysstat
        tmux-mem-cpu-load
      ];
  };
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = catppuccin;
        extraConfig = /* tmux */ ''
          set -g @catppuccin_icon_window_activity "󱅫 "
          set -g @catppuccin_icon_window_bell "󰂞 "
          set -g @catppuccin_icon_window_current "󰖯 "
          set -g @catppuccin_icon_window_last "󰖰 "
          set -g @catppuccin_icon_window_mark "󰃀 "
          set -g @catppuccin_icon_window_silent "󰂛 "
          set -g @catppuccin_icon_window_zoom "󰁌 "
          # set -g @catppuccin_status_modules_right "application session date_time"
          set -g @catppuccin_window_right_separator "█"
          set -g @catppuccin_window_status_enable "yes"
        '';
      }
      # cpu
    ];
    prefix = "C-\\\\";
    secureSocket = false;
    terminal = "tmux-256color";
    extraConfig = /* tmux */ ''
      set-option -g status-interval 1
      set-option -g status-position top

      set-option -a terminal-features ",*:RGB"

      # undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      # underscore colours - needs tmux-3.0
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      set -g visual-activity off
      # To enable Yazi's image preview to work correctly in tmux
      set -gq allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # automatically renumber windows
      set -g renumber-windows on

      bind R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # '@pane-is-vim' is a pane-local option that is set by the plugin on load,
      # and unset when Neovim exits or suspends; note that this means you'll probably
      # not want to lazy-load smart-splits.nvim, as the variable won't be set until
      # the plugin is loaded

      # Smart pane switching with awareness of Neovim splits.
      bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h'  'select-pane -L'
      bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j'  'select-pane -D'
      bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k'  'select-pane -U'
      bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l'  'select-pane -R'

      # Alternatively, if you want to disable wrapping when moving in non-neovim panes, use these bindings
      # bind-key -n C-h if -F '#{@pane-is-vim}' { send-keys C-h } { if -F '#{pane_at_left}'   "" 'select-pane -L' }
      # bind-key -n C-j if -F '#{@pane-is-vim}' { send-keys C-j } { if -F '#{pane_at_bottom}' "" 'select-pane -D' }
      # bind-key -n C-k if -F '#{@pane-is-vim}' { send-keys C-k } { if -F '#{pane_at_top}'    "" 'select-pane -U' }
      # bind-key -n C-l if -F '#{@pane-is-vim}' { send-keys C-l } { if -F '#{pane_at_right}'  "" 'select-pane -R' }

      # Smart pane resizing with awareness of Neovim splits.
      bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
      bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
      bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
      bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      set -g status-right "#[bg=#{@thm_flamingo},fg=#{@thm_crust}]#[reverse]#[noreverse]󰊚  "
      set -ag status-right "#[fg=#{@thm_fg},bg=#{@thm_mantle}] #(tmux-mem-cpu-load) "
      set -ag status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"
    '';
  };
}
