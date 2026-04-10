{ config, pkgs, ... }:
{
  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        # syntax-theme = "Nord";
      };
    };
    git = {
      enable = true;
      lfs.enable = true;
      includes = [
        { path = "${config.xdg.configHome}/gitalias/gitalias.txt"; }
      ];
      settings = {
        user = {
          email = "ozgezer@gmail.com";
          name = "Ahmet Cemal Özgezer";
        };
        # below configuration breaks magit
        branch.sort = "-committerdate";
        diff.colorMoved = "default";
        difftool.prompt = true;
        fetch.prune = true;
        github.user = "acml";
        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
        mergetool.prompt = true;
        push = {
          autoSetupRemote = true;
          followTags = true;
        };
        rebase = {
          autoStash = true;
          updateRefs = true;
        };
        rerere.enabled = true;
      };
    };
  };

  home.packages = with pkgs; [
    git-critique
    git-extras
    util-linux # git-extras#git summary:line 202 'column'
    # git-toolbelt
  ];

  home.shellAliases = rec {
    g = "git";
  };

  # link gitalias.txt from store to
  # $XDG_CONFIG_HOME/gitalias/gitalias.txt
  # nix run nixpkgs#nurl https://github.com/GitAlias/gitalias/
  xdg.configFile = {
    "gitalias/gitalias.txt".source =
      pkgs.fetchFromGitHub {
        # fill with snippet here
        owner = "GitAlias";
        repo = "gitalias";
        rev = "08b0fb7d4be46a4cca8e5b33df60b02f3b05ad02";
        hash = "sha256-hNuv3BjUsXEd+k6xR92F3XCsvoQrcutNxyNUsK7UYnk=";
      }
      + "/gitalias.txt";
  };
}
