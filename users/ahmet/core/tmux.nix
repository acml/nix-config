{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      sensible
      vim-tmux-navigator
    ];
    secureSocket = false;
    extraConfig = ''
      set-option -g status-position top
      set -ag terminal-overrides ",alacritty*:RGB,foot*:RGB,xterm-kitty*:RGB,xterm-256color:RGB"
      set -as terminal-features ",alacritty*:RGB,foot*:RGB,xterm-kitty*:RGB,xterm-256color:RGB"
      bind R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
