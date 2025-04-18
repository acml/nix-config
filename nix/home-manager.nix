{ withSystem, inputs, ... }:
let
  inherit (inputs) self home-manager nixpkgs;
  inherit (nixpkgs) lib;

  genModules =
    hostName:
    { homeDirectory, ... }:
    { config, pkgs, ... }:
    {
      imports = [ (../hosts + "/${hostName}") ];
      nix.registry = {
        nixpkgs.flake = nixpkgs;
        p.flake = nixpkgs;
      };

      home = {
        packages = [
          pkgs.wslu
        ];
        inherit homeDirectory;
        sessionVariables.NIX_PATH = lib.concatStringsSep ":" [
          "nixpkgs=${config.xdg.dataHome}/nixpkgs"
        ];
        sessionVariables.BROWSER = "wslview";
      };

      programs.fish.plugins = [
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
            hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk";
          };
        }
      ];

      xdg = {
        dataFile.nixpkgs.source = nixpkgs;
        configFile."nix/nix.conf".text = ''
          flake-registry = ${config.xdg.configHome}/nix/registry.json
        '';
        # Workaround for HM passing a nonexistent units dir to sd-switch
        # FIXME: https://github.com/nix-community/home-manager/issues/5552
        configFile."systemd/user/.hm-keep".text = "";
      };
    };

  genConfiguration =
    hostName:
    { hostPlatform, type, ... }@attrs:
    withSystem hostPlatform (
      { pkgs, ... }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ (genModules hostName attrs) ];
        extraSpecialArgs = {
          hostType = type;
          inherit (inputs)
            tinted-schemes
            impermanence
            nix-index-database
            nixvim
            catppuccin
            stylix
            ;
        };
      }
    );
in
lib.mapAttrs genConfiguration (lib.filterAttrs (_: host: host.type == "home-manager") self.hosts)
