{
  lib,
  hostType,
  pkgs,
  ...
}:
{
  xdg = {
    configFile."kitty/relative_resize.py" = {
      source = ./relative_resize.py;
      executable = true;
    };
  };

  programs.kitty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.hello else pkgs.kitty;
    extraConfig = ''
      map ctrl+j neighboring_window down
      map ctrl+k neighboring_window up
      map ctrl+h neighboring_window left
      map ctrl+l neighboring_window right

      # Unset the mapping to pass the keys to neovim
      map --when-focus-on var:IS_NVIM ctrl+j
      map --when-focus-on var:IS_NVIM ctrl+k
      map --when-focus-on var:IS_NVIM ctrl+h
      map --when-focus-on var:IS_NVIM ctrl+l

      # the 3 here is the resize amount, adjust as needed
      map alt+j kitten relative_resize.py down  3
      map alt+k kitten relative_resize.py up    3
      map alt+h kitten relative_resize.py left  3
      map alt+l kitten relative_resize.py right 3

      map --when-focus-on var:IS_NVIM alt+j
      map --when-focus-on var:IS_NVIM alt+k
      map --when-focus-on var:IS_NVIM alt+h
      map --when-focus-on var:IS_NVIM alt+l

      symbol_map U+2026 IosevkaTerm Nerd Font
      symbol_map U+2600-U+26FF Noto Color Emoji

      # Seti-UI + Custom
      symbol_map  U+e5fa-U+e6b5 IosevkaTerm Nerd Font

      # Devicons
      symbol_map U+e700-U+e7c5 IosevkaTerm Nerd Font

      # Font Awesome (with a gap)
      symbol_map U+ed00-U+f2ff IosevkaTerm Nerd Font

      # Font Awesome Extension
      symbol_map U+e200-U+e2a9 IosevkaTerm Nerd Font

      # Material Design Icons
      symbol_map U+f0001-U+f1af0 IosevkaTerm Nerd Font

      # Weather
      symbol_map U+e300-U+e3e3 IosevkaTerm Nerd Font

      # Octicons
      symbol_map U+f400-U+f533,U+2665,U+26A1 IosevkaTerm Nerd Font

      # Powerline Symbols
      symbol_map U+e0a0-U+e0a2,U+e0b0-U+e0b3 IosevkaTerm Nerd Font

      # Powerline Extra Symbols
      symbol_map U+e0a3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7 IosevkaTerm Nerd Font

      # IEC Power Symbols
      symbol_map U+23fb-U+23fe,U+2b58 IosevkaTerm Nerd Font

      # Font Logos
      symbol_map U+f300-U+f375 IosevkaTerm Nerd Font

      # Pomicons
      symbol_map U+e000-U+e00a IosevkaTerm Nerd Font

      # Codicons
      symbol_map U+ea60-U+ec1e IosevkaTerm Nerd Font

      # Additional sets - Heavy Angle Brackets
      symbol_map U+276c-U+2771 IosevkaTerm Nerd Font

      # Additional sets - Box Drawing
      symbol_map U+2500-U+259f IosevkaTerm Nerd Font
    '';
    font = {
      package = pkgs.iosevka-comfy.comfy;
      name = "Iosevka Comfy";
      size = 15.0;
    };
    settings = {
      scrollback_lines = 5000;
      scrollback_pager_history_size = 32768;
      strip_trailing_spaces = "smart";
      repaint_delay = 16; # ~60Hz
      enable_audio_bell = false;
      update_check_interval = 0;
      allow_remote_control = true;
    }
    // (lib.optionalAttrs (hostType == "darwin")) {
      listen_on = "unix:/tmp/mykitty";
      macos_show_window_title_in = "window";
      macos_colorspace = "default";
    }
    // (lib.optionalAttrs (hostType == "linux")) {
      listen_on = "unix:@mykitty";
    };

    darwinLaunchOptions = [
      "--single-instance"
      "--directory=~"
    ];
  };
}
