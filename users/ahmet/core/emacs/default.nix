{ config, pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  DOOMDIR = "${config.xdg.configHome}/doom";
  DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
  EMACSDIR = "${config.xdg.configHome}/emacs";
  # EDITOR = "emacsclient -tc";
  ALTERNATE_EDITOR = "emacs";
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

      packages = with pkgs; [
        # fonts
        emacs-all-the-icons-fonts
        julia-mono
        noto-fonts-emoji
        symbola
        (nerdfonts.override {
          fonts = [
            "FiraCode"
            "IBMPlexMono"
            "Iosevka"
            "Overpass"
            "NerdFontsSymbolsOnly"
          ];
        })

        (lib.mkIf isDarwin coreutils-prefixed)
        (lib.mkIf isDarwin pngpaste)

        exercism

        ## Doom dependencies
        (ripgrep.override { withPCRE2 = true; })
        # ripgrep-all

        ## Optional dependencies
        dtach
        fd # faster projectile indexing
        imagemagick # for image-dired
        unzip
        zstd # for undo-fu-session/undo-tree compression

        ## Module dependencies

        # :checkers spell
        (aspellWithDicts (dicts: with dicts; [ en en-computers en-science tr ]))

        # :checkers grammar
        languagetool

        # :tools editorconfig
        editorconfig-core-c # per-project style config

        # :tools lookup & :lang org +roam
        sqlite
        (lib.mkIf isLinux maim) # org-download-clipboard
        gnuplot # org-plot/gnuplot
        graphviz # org-roam-graph
        # :lang latex & :lang org (latex previews)
        tectonic

        # :lang cc
        clang-tools
        glslang

        # CMake LSP
        cmake
        cmake-language-server

        # Nix
        nixfmt-classic
        # nil

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

        trash-cli
      ] ++ lib.optionals stdenv.hostPlatform.isLinux [
        man-pages
        man-pages-posix

        # :app everywhere
        wl-clipboard
        xclip
        xdotool
        xsel
      ];

      sessionPath = [ "${EMACSDIR}/bin" ];
      sessionVariables = {
        inherit DOOMDIR DOOMLOCALDIR
          # EDITOR
          ALTERNATE_EDITOR;
      };
    };

    systemd.user.sessionVariables = lib.mkIf isLinux {
      inherit DOOMDIR DOOMLOCALDIR
        # EDITOR
        ALTERNATE_EDITOR;
    };

    xdg = {
      configFile."doom" = {
        source = ./doom.d;
        force = true;
      };
      dataFile = {
        "doom/etc/lsp/lua-language-server/main.lua".source = "${pkgs.lua-language-server}/share/lua-language-server/bin/main.lua";
        "doom/etc/lsp/lua-language-server/bin/lua-language-server".source = "${pkgs.lua-language-server}/bin/lua-language-server";
      };
    };

    programs = {
      emacs = {
        enable = true;
        package = lib.mkMerge [
          (lib.mkIf isLinux pkgs.emacs29)
          (lib.mkIf isDarwin pkgs.emacs29)
        ];
        extraPackages = epkgs: (with epkgs; [
          pdf-tools
          treesit-grammars.with-all-grammars
          vterm
        ]);
      };

      jq.enable = true; # cli to extract data out of json input
      man.enable = true;
      man.generateCaches = true;
    };
  }

  # user systemd service for Linux
  (lib.mkIf isLinux {
    services.emacs = {
      enable = true;
      # The client is already provided by the Doom Emacs final package
      client.enable = false;
    };
  })
]
