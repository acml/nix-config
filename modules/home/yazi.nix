{ pkgs, flake, ... }:
{
  programs = {
    yazi = {
      enable = true;
      extraPackages = with pkgs; [
        ffmpeg
        imagemagick
        mediainfo
        ouch
        trash-cli
      ];
      initLua = # lua
        ''
          require("git"):setup()
          require("recycle-bin"):setup()
        '';
      flavors =
        let
          flavors = flake.inputs.yazi-flavors;
        in
        {
          catppuccin-frappe = "${flavors}/catppuccin-frappe.yazi";
          catppuccin-latte = "${flavors}/catppuccin-latte.yazi";
          catppuccin-macchiato = "${flavors}/catppuccin-macchiato.yazi";
          catppuccin-mocha = "${flavors}/catppuccin-mocha.yazi";
        };
      theme = {
        flavor = {
          dark = "catppuccin-macchiato";
          light = "catppuccin-frappe";
        };
      };
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
          {
            on = [
              "g"
              "p"
            ];
            run = "cd ~/Projects";
            desc = "Cd to ~/Projects";
          }
          {
            on = [
              "g"
              "w"
            ];
            run = "cd ~/Work";
            desc = "Cd to ~/Work";
          }
          {
            on = [
              "R"
              "b"
            ];
            run = "plugin recycle-bin";
            desc = "Open Recycle Bin menu";
          }
        ];
      };
      plugins = with pkgs.yaziPlugins; {
        inherit bypass;
        inherit chmod;
        inherit git;
        inherit mediainfo;
        inherit ouch;
        inherit recycle-bin;
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
