{ pkgs, ... }:
{
  programs = {
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
  };
}
