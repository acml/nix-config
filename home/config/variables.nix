{ config, pkgs, lib, ... }:
{
  config.home.sessionVariables = lib.mkMerge [
    rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;
      PAGER = "vimpager";
    }

    (lib.mkIf config.isDesktop {
      SSH_ASKPASS = "${pkgs.gnome3.seahorse}/libexec/seahorse/ssh-askpass";
      DESKTOP_SESSION = "gnome";
      ECORE_EVAS_ENGINE = "wayland_egl";
      ELM_ENGINE = "wayland_egl";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_WAYLAND_FORCE_DPI = "physical";
      SDL_VIDEODRIVER = "wayland";
      XDG_CURRENT_DESKTOP = "GNOME";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    })
  ];
}
