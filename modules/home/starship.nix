_: {
  programs.starship = {
    enable = true;
  };
  # xdg.configFile."starship.toml".source = lib.mkForce ./starship.toml;
}
