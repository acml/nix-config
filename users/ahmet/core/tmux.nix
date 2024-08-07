{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      sensible
    ];
    secureSocket = false;
    extraConfig = ''
      set-option -g status-position top

      # To enable Yazi's image preview to work correctly in tmux
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # set -ag terminal-overrides ",alacritty*:RGB,foot*:RGB,xterm-kitty*:RGB,xterm-256color:RGB"
      # set -as terminal-features ",alacritty*:RGB,foot*:RGB,xterm-kitty*:RGB,xterm-256color:RGB"
      set -sg terminal-overrides ",*:RGB"
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

      bind-key -n 'C-\' if -F "#{@pane-is-vim}" 'send-keys C-\\'  'select-pane -l'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
    '';
  };
}
