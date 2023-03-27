{ pkgs, hostType, impermanence, nix-index-database, stylix, ... }: {
  imports = [
    (
      if hostType == "nixos" then ./nixos.nix
      else if hostType == "darwin" then ./darwin.nix
      else throw "Unknown hostType '${hostType}' for core"
    )
    ./aspell.nix
    ./nix.nix
  ];

  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
  };

  environment = {
    pathsToLink = [
      "/share/fish"
      "/share/zsh"
    ];
    systemPackages = with pkgs; [
      man-pages
      neovim
      rsync
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit hostType impermanence nix-index-database stylix;
    };
  };

  programs = {
    nix-index.enable = true;
    fish.enable = true;
    zsh.enable = true;
  };
}
