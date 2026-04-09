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

  home.shellAliases = rec {
    g = "git";
    git_what_changes_the_most = "git log --format=format: --name-only --since='1 year ago' | sort | uniq -c | sort -nr | head -20";
    git_who_built_this = "git shortlog -sn --no-merges";
    git_where_do_bugs_cluster = "git log -i -E --grep='fix|bug|broken' --name-only --format='' | sort | uniq -c | sort -nr | head -20";
    git_is_this_project_accelerating_or_dying = "git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c";
    git_how_often_is_the_team_firefighting = "git log --oneline --since='1 year ago' | grep -iE 'revert|hotfix|emergency|rollback'";
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
