{ pkgs, ... }: {
  home.packages = with pkgs; [ beets bimp fixart lollypop imagemagick essentia-extractor ];
}
