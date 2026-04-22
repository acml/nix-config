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

  # Define the base Emacs package to use
  emacsPackage =
    if isDarwin then
      pkgs.emacs-git-pgtk.overrideAttrs (old: {
        passthru = old.passthru // {
          treeSitter = true;
        };
        patches = (old.patches or [ ]) ++ [
          ./skip_ns_color_initialization_in_batch_mode.patch
          # Refresh x-colors during NS window system initializatio
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-31/fix-ns-x-colors.patch";
            hash = "sha256-oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=";
          })
          # Enable rounded window with no decoration
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-31/round-undecorated-frame.patch";
            hash = "sha256-WWLg7xUqSa656JnzyUJTfxqyYB/4MCAiiiZUjMOqjuY=";
          })
          # Make Emacs aware of OS-level light/dark mode
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-31/system-appearance.patch";
            hash = "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
          })
        ];
      })
    else
      pkgs.emacs-git.overrideAttrs (old: {
        passthru = old.passthru // {
          treeSitter = true;
        };
      });
  # Common Emacs packages
  emacsWithPackages = (pkgs.emacsPackagesFor emacsPackage).emacsWithPackages (
    epkgs:
    with epkgs;
    lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [
      copilot
      djvu
      emacsql
      tree-sitter-langs
      treesit-grammars.with-all-grammars
      # (treesit-grammars.with-grammars (
      #   grammars: with grammars; [
      #     tree-sitter-bash
      #     tree-sitter-c
      #     tree-sitter-cmake
      #     tree-sitter-cpp
      #     tree-sitter-css
      #     tree-sitter-dockerfile
      #     tree-sitter-elisp
      #     tree-sitter-go
      #     tree-sitter-gomod
      #     tree-sitter-hcl
      #     tree-sitter-html
      #     tree-sitter-java
      #     tree-sitter-javascript
      #     tree-sitter-jsdoc
      #     tree-sitter-json
      #     tree-sitter-json5
      #     tree-sitter-latex
      #     tree-sitter-lua
      #     tree-sitter-make
      #     tree-sitter-nix
      #     tree-sitter-nu
      #     tree-sitter-php
      #     tree-sitter-python
      #     tree-sitter-ruby
      #     tree-sitter-rust
      #     tree-sitter-sql
      #     tree-sitter-toml
      #     tree-sitter-tsx
      #     tree-sitter-typescript
      #     tree-sitter-yaml
      #     tree-sitter-zig
      #   ]
      # ))
      vterm
    ]
    ++ lib.optionals isDarwin [
      pdf-tools
    ]
    ++ lib.optionals isLinux [
      (melpaBuild {
        ename = "reader";
        pname = "emacs-reader";
        version = "20260414";
        src = pkgs.fetchFromGitea {
          domain = "codeberg.org";
          owner = "divyaranjan";
          repo = "emacs-reader";
          rev = "9824fc91eb"; # replace with 'version' for stable
          hash = "sha256-84v8NzAjH0djD98RKElzy3dIkSSh1c3OyjrHXR8cQrY=";
        };
        files = ''(:defaults "render-core.so")'';
        nativeBuildInputs = with pkgs; [ pkg-config ];
        buildInputs = with pkgs; [
          mupdf-headless
        ];
        preBuild = ''
          export EMACSLOADPATH=".:$EMACSLOADPATH"
          make clean all CC=$CC USE_PKGCONFIG=yes
        '';
      })
    ]
  );

  # Define language servers and tools to include in PATH for Emacs
  extraPackages =
    with pkgs;
    [
      # Language Servers
      # go # Go language
      # gopls # Go language server
      # bash-language-server # Bash language server
      # dockerfile-language-server # Docker language server
      # intelephense # PHP language server
      # typescript-language-server # JS/TS language server
      # vscode-langservers-extracted # CSS/LESS/SASS language server
      # nodejs # For copilot.el

      # Other programs
      # gnuplot # For use with org mode
      # phpPackages.php-codesniffer # PHP codestyle checker
      # openscad # For use with scad and scad preview mode

      emacs-lsp-booster

      # Optional dependencies
      dtach
      exiftool # for image-dired
      fd # faster projectile indexing
      graphicsmagick # for image-dired
      libjpeg # for image-dired
      unzip
      zstd # for undo-fu-session/undo-tree compression

      # Module dependencies

      # :checkers grammar
      languagetool

      # :tools editorconfig
      dockfmt

      # :tools editorconfig
      editorconfig-core-c # per-project style config

      # :tools lookup & :lang org +roam
      sqlite
      wordnet
      gnuplot # org-plot/gnuplot
      graphviz # org-roam-graph
      # :lang latex & :lang org (latex previews)
      tectonic

      # :lang cc
      # ccls
      clang-tools
      glslang

      # CMake LSP
      cmake
      cmake-language-server

      #data
      libxml2 # xmllint

      # Nix
      nixfmt
      nil

      # Markdown exporting
      mdl
      pandoc

      # HTML/CSS/JSON language servers
      prettier
      vscode-langservers-extracted

      # Yaml
      yaml-language-server

      # Bash
      bash-language-server
      shellcheck
      shfmt

      # :lang lua
      # (lib.mkIf isLinux sumneko-lua-language-server)
      lua-language-server

      # dirvish previewers
      epub-thumbnailer
      ffmpegthumbnailer
      mediainfo
      p7zip
      poppler-utils
      vips

      zip
    ]
    ++ lib.optionals isLinux [
      maim # org-download-clipboard
    ]
    ++ lib.optionals isDarwin [
      coreutils-prefixed
      pngpaste
    ];

  # Wrap emacs to add language servers to PATH, keeping user environment clean
  wrappedEmacs = pkgs.symlinkJoin {
    name = "${emacsWithPackages.name}-wrapped";
    paths = [ emacsWithPackages ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      # Wrap all emacs binaries with language servers in PATH
      for bin in $out/bin/*; do
        wrapProgram "$bin" \
          --prefix PATH : ${lib.makeBinPath extraPackages}
      done
    '';

    # Preserve meta attributes from the original package
    inherit (emacsWithPackages) meta;
  };
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

          exercism

          ## Doom dependencies

          # :checkers spell
          (aspellWithDicts (
            dicts: with dicts; [
              en
              en-computers
              en-science
              tr
            ]
          ))

          # Python LSP setup
          # pyright
          # pipenv
          # (python3.withPackages (ps: with ps; [
          #   black isort pyflakes pytest
          # ]))

          # JavaScript
          # typescript-language-server

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
          xwininfo
          xprop
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
      shellAliases = {
        e = "emacs -nw";
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
        package = wrappedEmacs;
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
      # package = wrappedEmacs;
      socketActivation.enable = true;
    };
  })
]
