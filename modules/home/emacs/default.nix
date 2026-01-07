{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  DOOMDIR = "${config.xdg.configHome}/doom";
  DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
  EMACSDIR = "${config.xdg.configHome}/emacs";
  # EDITOR = "emacsclient -tc";
  ALTERNATE_EDITOR = "emacs";
  myEmacs = lib.mkMerge [
    (lib.mkIf isLinux pkgs.emacs30)
    (lib.mkIf isDarwin (
      pkgs.emacs30-pgtk.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          # Fix OS window role (needed for window managers like yabai)
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
            sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
          })
          # Enable rounded window with no decoration
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/round-undecorated-frame.patch";
            sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
          })
          # Make Emacs aware of OS-level light/dark mode
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/system-appearance.patch";
            sha256 = "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
          })
        ];
      })
    ))
  ];
in
lib.mkMerge [
  {
    fonts.fontconfig.enable = true;

    home = {
      activation = {
        emacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d "${EMACSDIR}" ]; then
            $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/doomemacs/doomemacs.git ${EMACSDIR} $VERBOSE_ARG
          fi
        '';
      };

      packages =
        with pkgs;
        [
          # fonts
          emacs-all-the-icons-fonts
          hack-font
          iosevka-comfy.comfy
          (lib.mkIf isLinux quivira)
          symbola
          unifont
          nerd-fonts.blex-mono
          nerd-fonts.iosevka
          nerd-fonts.iosevka-term
          nerd-fonts.symbols-only
          nerd-fonts.overpass

          (lib.mkIf isDarwin coreutils-prefixed)
          (lib.mkIf isDarwin pngpaste)

          exercism

          ## Doom dependencies

          ## Optional dependencies
          dtach
          exiftool # for image-dired
          fd # faster projectile indexing
          graphicsmagick # for image-dired
          libjpeg # for image-dired
          unzip
          zstd # for undo-fu-session/undo-tree compression

          ## Module dependencies

          # :checkers spell
          (aspellWithDicts (
            dicts: with dicts; [
              en
              en-computers
              en-science
              tr
            ]
          ))

          # :checkers grammar
          languagetool

          # :tools editorconfig
          editorconfig-core-c # per-project style config

          # :tools lookup & :lang org +roam
          sqlite
          wordnet
          (lib.mkIf isLinux maim) # org-download-clipboard
          gnuplot # org-plot/gnuplot
          graphviz # org-roam-graph
          # :lang latex & :lang org (latex previews)
          tectonic

          # :lang cc
          # ccls
          clang-tools
          glslang

          emacs-lsp-booster

          # CMake LSP
          cmake
          cmake-language-server

          # Nix
          nixfmt-classic
          nil

          # Markdown exporting
          mdl
          pandoc

          # Python LSP setup
          # nodePackages.pyright
          # pipenv
          # (python3.withPackages (ps: with ps; [
          #   black isort pyflakes pytest
          # ]))

          # JavaScript
          # nodePackages.typescript-language-server

          # HTML/CSS/JSON language servers
          nodePackages.prettier
          nodePackages.vscode-langservers-extracted

          # Yaml
          nodePackages.yaml-language-server

          # Bash
          nodePackages.bash-language-server
          shellcheck
          shfmt

          # :lang lua
          # (lib.mkIf isLinux sumneko-lua-language-server)
          lua-language-server

          # Rust
          # cargo
          # cargo-audit
          # cargo-edit
          # clippy
          # rust-analyzer
          # rustfmt
          # rustc.out

          # :lang go
          # go_1_18
          # delve # vscode
          # go-outline # vscode
          # go-tools # vscode (staticcheck)
          # golint # vscode
          # gomodifytags # vscode
          # gopkgs # vscode
          # gopls # vscode
          # gotests # vscode
          # impl # vscode
          # gocode
          # golangci-lint
          # gore
          # gotools

          # dirvish previewers
          epub-thumbnailer
          ffmpegthumbnailer
          mediainfo
          p7zip
          poppler-utils
          vips

          trash-cli
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          man-pages
          man-pages-posix

          # :app everywhere
          # wl-clipboard
          xclip
          xdotool
          xsel

          zip
        ];

      sessionPath = [ "${EMACSDIR}/bin" ];
      sessionVariables = {
        inherit
          DOOMDIR
          DOOMLOCALDIR
          # EDITOR
          ALTERNATE_EDITOR
          ;
      };
    };

    systemd.user.sessionVariables = lib.mkIf isLinux {
      inherit
        DOOMDIR
        DOOMLOCALDIR
        # EDITOR
        ALTERNATE_EDITOR
        ;
    };

    xdg = {
      configFile."doom" = {
        source = ./doom.d;
        force = true;
      };
      dataFile = {
        "doom/etc/lsp/lua-language-server/main.lua".source =
          "${pkgs.lua-language-server}/share/lua-language-server/bin/main.lua";
        "doom/etc/lsp/lua-language-server/bin/lua-language-server".source =
          "${pkgs.lua-language-server}/bin/lua-language-server";
      };
    };

    programs = {
      emacs = {
        enable = true;
        package = myEmacs;
        extraPackages =
          epkgs:
          (
            with epkgs;
            lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [
              copilot
              djvu
              emacsql
              # treesit-grammars.with-all-grammars
              (treesit-grammars.with-grammars (
                grammars: with grammars; [
                  tree-sitter-bash
                  tree-sitter-c
                  tree-sitter-cmake
                  tree-sitter-cpp
                  tree-sitter-css
                  tree-sitter-dockerfile
                  tree-sitter-elisp
                  tree-sitter-go
                  tree-sitter-gomod
                  tree-sitter-hcl
                  tree-sitter-html
                  tree-sitter-java
                  tree-sitter-javascript
                  tree-sitter-jsdoc
                  tree-sitter-json
                  tree-sitter-json5
                  tree-sitter-latex
                  tree-sitter-lua
                  tree-sitter-make
                  tree-sitter-nix
                  tree-sitter-nu
                  tree-sitter-php
                  tree-sitter-python
                  tree-sitter-ruby
                  tree-sitter-rust
                  tree-sitter-sql
                  tree-sitter-toml
                  tree-sitter-tsx
                  tree-sitter-typescript
                  tree-sitter-yaml
                  tree-sitter-zig
                ]
              ))
              vterm
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
              pdf-tools
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              (melpaBuild {
                ename = "reader";
                pname = "emacs-reader";
                version = "20251221";
                src = pkgs.fetchFromGitea {
                  domain = "codeberg.org";
                  owner = "divyaranjan";
                  repo = "emacs-reader";
                  rev = "b47c119e9c"; # replace with 'version' for stable
                  hash = "sha256-WLs/wdTyGSdOQqbTn4Tzrx9mcpBCADuc7dIWR1JdIAQ=";
                };
                files = ''(:defaults "render-core.so")'';
                nativeBuildInputs = with pkgs; [ pkg-config ];
                buildInputs = with pkgs; [
                  mupdf-headless
                ];
                preBuild = "make clean all";
              })
            ]
          );
      };

      jq.enable = true; # cli to extract data out of json input
      man.enable = true;
      man.generateCaches = true;
    };
  }

  # user systemd service for Linux
  (lib.mkIf isLinux {
    services.emacs = {
      enable = false;
      client = {
        enable = true;
        arguments = [
          "--no-wait"
          "--create-frame"
          # "--alternate-editor=\"\""
        ];
      };
      package = myEmacs;
      socketActivation.enable = true;
    };
  })
]
