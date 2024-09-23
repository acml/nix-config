{ lib, hostType, pkgs, ... }: {
  xdg = {
    configFile."kitty/relative_resize.py" = {
      source = ./relative_resize.py;
      executable = true;
    };
  };
  programs.kitty = {
    enable = true;
    extraConfig = "
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
      ";
    font = {
      package = pkgs.iosevka-comfy.comfy;
      name = "Iosevka Comfy";
      size = 14.0;
    };
    settings = {
      scrollback_lines = 5000;
      scrollback_pager_history_size = 32768;
      strip_trailing_spaces = "smart";
      repaint_delay = 16; # ~60Hz
      enable_audio_bell = false;
      update_check_interval = 0;
      allow_remote_control = true;
    } // (lib.optionalAttrs (hostType == "darwin")) {
      listen_on = "unix:/tmp/mykitty";
      macos_show_window_title_in = "window";
      macos_colorspace = "default";
    } // (lib.optionalAttrs (hostType == "linux")) {
      listen_on = "unix:@mykitty";
    };

    darwinLaunchOptions = [ "--single-instance" "--directory=~" ];
  };
}
