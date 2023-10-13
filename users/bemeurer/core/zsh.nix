{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableVteIntegration = pkgs.stdenv.isLinux;
    autocd = true;
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "${config.xdg.dataHome}/zsh/history";
      save = 10000;
      share = true;
    };
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
    envExtra = ''
      export LESSHISTFILE="${config.xdg.dataHome}/less_history"
      export CARGO_HOME="${config.xdg.cacheHome}/cargo"
    '';
    initExtra = ''
      nix-closure-size() {
        nix-store -q --size $(nix-store -qR $(${pkgs.coreutils}/bin/readlink -e $1) ) |
          ${pkgs.gawk}/bin/gawk '{ a+=$1 } END { print a }' |
          ${pkgs.coreutils}/bin/numfmt --to=iec-i
      }

      bindkey "$${terminfo[khome]}" beginning-of-line
      bindkey "$${terminfo[kend]}" end-of-line
      bindkey "$${terminfo[kdch1]}" delete-char
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;3D" backward-word
      bindkey -s "^O" 'fzf | xargs -r $EDITOR^M'

      bindkey -rpM viins '^[^['
      KEYTIMEOUT=1

      ${pkgs.nix-your-shell}/bin/nix-your-shell zsh | source /dev/stdin
      # 1Password CLI
      if [ -e "$HOME/.config/op/plugins.sh" ]; then
        source "$HOME/.config/op/plugins.sh"
      fi
    '';
    sessionVariables = {
      RPROMPT = "";
    };
    plugins = [
      {
        # https://github.com/softmoth/zsh-vim-mode
        name = "zsh-vim-mode";
        file = "zsh-vim-mode.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "softmoth";
          repo = "zsh-vim-mode";
          rev = "abef0c0c03506009b56bb94260f846163c4f287a";
          sha256 = "0cnjazclz1kyi13m078ca2v6l8pg4y8jjrry6mkvszd383dx1wib";
        };
      }
      {
        # https://github.com/hlissner/zsh-autopair
        name = "zsh-autopair";
        file = "zsh-autopair.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
      }
    ];
  };
}
