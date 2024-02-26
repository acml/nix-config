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
        export PATH="$PATH:$HOME/.toolbox/bin:/apollo/env/bt-rust/bin"
      '';
    };
    fish.shellInit = ''
      fish_add_path --append --path "$HOME/.toolbox/bin"
      fish_add_path --append --path "/apollo/env/bt-rust/bin"
    '';
    git.userEmail = lib.mkForce "ozgezer@gmail.com";
    zsh = {
      initExtraBeforeCompInit = ''
        fpath+=("$HOME/.zsh/completion")
      '';
      initExtra = ''
        export PATH="$PATH:$HOME/.toolbox/bin:/apollo/env/bt-rust/bin"
      '';
    };
  };
}
