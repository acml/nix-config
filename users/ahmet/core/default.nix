{
  tinted-schemes,
  hostType,
  impermanence,
  lib,
  nix-index-database,
  pkgs,
  nixvim,
  catppuccin,
  stylix,
  ...
}:
{
  imports = [
    impermanence.nixosModules.home-manager.impermanence
    nix-index-database.homeModules.nix-index
    nixvim.homeManagerModules.nixvim
    catppuccin.homeModules.catppuccin
    stylix.homeModules.stylix

    ./bash.nix
    ./btop.nix
    ./fish.nix
    ./git.nix
    ./htop.nix
    ./emacs
    ./nixvim
    # ./neovim.nix
    ./ssh.nix
    ./starship.nix
    # ./tmux.nix
    ./xdg.nix
    ./zsh.nix
  ];

  # XXX: Manually enabled in the graphic module
  dconf.enable = false;

  home = {
    username = "ahmet";
    stateVersion = "23.05";
    packages =
      with pkgs;
      [
        eza
        fd
        fzf
        mediainfo
        neofetch
        nix-closure-size
        nix-output-monitor
        ouch
        ripgrep
        rsync
        truecolor-check
      ]
      ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
        mosh
      ];
    shellAliases = {
      cat = "bat";
      cls = "clear";
      l = "ls";
      la = "ls --all";
      ls = "eza --binary --header --long --icons";
      man = "batman";
    };
  };

  programs = {
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        enter_accept = true;
        show_help = false;
        update_check = false;
        workspaces = true;
      };
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
    };
    gpg.enable = true;
    nix-index.enable = true;
    yazi = {
      enable = true;
      initLua = # lua
        ''
          require("git"):setup()
          local catppuccin_theme = require("yatline-catppuccin"):setup("mocha") -- or "latte" | "frappe" | "macchiato"
          require("yatline"):setup({
            theme = catppuccin_theme,

            tab_width = 20,
            tab_use_inverse = false,

            show_background = true,

            display_header_line = true,
            display_status_line = true,

            component_positions = { "header", "tab", "status" },

            header_line = {
              left = {
                section_a = { {type = "line", custom = false, name = "tabs", params = {"left"}}, },
                section_b = { },
                section_c = { }
              },
              right = {
                section_a = { {type = "string", custom = false, name = "date", params = {"%A, %d %B %Y"}}, },
                section_b = { {type = "string", custom = false, name = "date", params = {"%X"}}, },
                section_c = { {type = "coloreds", custom = false, name = "githead"}, }
              }
            },

            status_line = {
              left = {
                section_a = { {type = "string", custom = false, name = "tab_mode"}, },
                section_b = { {type = "string", custom = false, name = "hovered_size"}, },
                section_c = {
                        {type = "string", custom = false, name = "hovered_path"},
                        {type = "coloreds", custom = false, name = "count"},
                }
              },
              right = {
                section_a = { {type = "string", custom = false, name = "cursor_position"}, },
                section_b = { {type = "string", custom = false, name = "cursor_percentage"}, },
                section_c = {
                        {type = "string", custom = false, name = "hovered_file_extension", params = {true}},
                        {type = "coloreds", custom = false, name = "permissions"},
                }
              }
            },
          })
          require("yatline-githead"):setup({
            theme = catppuccin_theme,
          })
        '';
      keymap = {
        mgr.prepend_keymap = [
          {
            on = [ "l" ];
            run = "plugin bypass smart-enter";
            desc = "Open a file, or recursively enter child directory, skipping children with only a single subdirectory";
          }
          {
            on = [ "h" ];
            run = "plugin bypass reverse";
            desc = "Recursively enter parent directory, skipping parents with only a single subdirectory";
          }
          {
            on = "q";
            run = "close";
            desc = "Close the current tab, or quit if it's last";
          }
          {
            on = [ "<C-c>" ];
            run = "plugin confirm-quit";
            desc = "Quit the process";
          }
          {
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = "C";
            run = "plugin ouch";
            desc = "Compress with ouch";
          }
        ];
      };
      plugins = with pkgs.yaziPlugins; {
        inherit bypass;
        inherit chmod;
        inherit git;
        inherit mediainfo;
        inherit ouch;
        inherit yatline;
        inherit yatline-catppuccin;
        inherit yatline-githead;
      };
      settings = {
        mgr = {
          ratio = [
            1
            2
            5
          ];
        };
        plugin = {
          prepend_fetchers = [
            {
              id = "git";
              name = "*";
              run = "git";
            }
            {
              id = "git";
              name = "*/";
              run = "git";
            }
          ];
          prepend_preloaders = [
            # Replace magick, image, video with mediainfo
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            # Adobe Illustrator
            {
              mime = "application/postscript";
              run = "mediainfo";
            }
          ];
          prepend_previewers = [
            # Replace magick, image, video with mediainfo
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            # Adobe Illustrator
            {
              mime = "application/postscript";
              run = "mediainfo";
            }
            # Archive previewer
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/vnd.rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
            {
              mime = "application/xz";
              run = "ouch";
            }
            {
              mime = "application/x-zstd";
              run = "ouch";
            }
            {
              mime = "application/zstd";
              run = "ouch";
            }
            {
              mime = "application/java-archive";
              run = "ouch";
            }
          ];
        };
      };
    };
    zellij = {
      enable = true;
      settings = {
        pane_frames = false;
        show_startup_tips = false;
      };
    };
    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
  };

  stylix = {
    enable = true;
    base16Scheme = "${tinted-schemes}/base16/catppuccin-mocha.yaml";
    # XXX: We fetchurl from the repo because flakes don't support git-lfs assets
    image = pkgs.fetchurl {
      url = "https://media.githubusercontent.com/media/lovesegfault/nix-config/bda48ceaf8112a8b3a50da782bf2e65a2b5c4708/users/bemeurer/assets/walls/plants-00.jpg";
      hash = "sha256-n8EQgzKEOIG6Qq7og7CNqMMFliWM5vfi2zNILdpmUfI=";
    };
    targets = {
      gnome.enable = hostType == "nixos";
      gtk.enable = hostType == "nixos";
      kde.enable = lib.mkDefault false;
      xfce.enable = lib.mkDefault false;
      bat.enable = lib.mkDefault false;
      btop.enable = lib.mkDefault false;
      emacs.enable = lib.mkDefault false;
      kitty.enable = lib.mkDefault false;
      nixvim.enable = lib.mkDefault false;
      starship.enable = lib.mkDefault false;
      yazi.enable = lib.mkDefault false;
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha"; # "latte" "frappe" "macchiato" "mocha"
    # accent = "rosewater"; # "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach" "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow"
    cursors.enable = false;
    mako.enable = false;
    starship.enable = false;
  };

  systemd.user.startServices = "sd-switch";

  xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
  xdg.configFile."yazi/plugins/confirm-quit.yazi/main.lua".text = ''
    local count = ya.sync(function() return #cx.tabs end)

    local function entry()
      if count() < 2 then
        return ya.emit("quit", {})
      end

      local yes = ya.confirm {
        pos = { "center", w = 60, h = 10 },
        title = "Quit?",
        content = ui.Text("There are multiple tabs open.\n\nAre you sure you want to quit?"):wrap(ui.Wrap.YES),
      }
      if yes then
        ya.emit("quit", {})
      end
    end

    return { entry = entry }
  '';
}
