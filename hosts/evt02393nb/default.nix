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
      '';
      profileExtra = ''
        if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
          source ~/.nix-profile/etc/profile.d/nix.sh
        fi
        if [ -n "''${WSLENV}" ] ; then
          export WAYLAND_DISPLAY='wayland-1'
          if command -v setxkbmap >/dev/null; then
            setxkbmap us -variant colemak
          fi
        fi

        if [ -f /etc/bashrc ]; then
        . /etc/bashrc
        fi
      '';
    };
    git.userEmail = lib.mkForce "ahmet.ozgezer@siemens.com";
  };
}