{ lib, pkgs, ... }: {
  home = {
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;
    };
    shellAliases = { vi = "nvim"; vim = "nvim"; };
  };

  programs = {
    git.extraConfig.core.editor = "nvim";

    neovim = {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        # ui
        bufferline-nvim # bufferline
        feline-nvim # statusline
        gitsigns-nvim # git status sign decorations
        indent-blankline-nvim # indentation guides
        lsp_signature-nvim # function signature pop-ups
        neovim-ayu # colorscheme
        numb-nvim # peek lines in non-obtrusive way
        nvim-lightbulb # lightbulb sign when LSP actions are available
        nvim-navic # status/bufferline component to show LSP context
        nvim-web-devicons # file icons for trouble-nvim
        stabilize-nvim
        todo-comments-nvim
        trouble-nvim # list for showing LSP diagnostics
        true-zen-nvim

        # tooling
        nvim-bufdel
        rust-tools-nvim
        suda-vim
        tabular
        telescope-frecency-nvim
        telescope-nvim
        vim-better-whitespace
        vim-commentary
        vim-fugitive
        vim-gist
        vim-rhubarb
        vim-sleuth
        vim-surround
        vim-tmux-navigator
        vim-visual-multi

        # completion
        cmp-buffer
        cmp-cmdline
        cmp-latex-symbols
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        cmp-treesitter
        cmp_luasnip
        crates-nvim
        null-ls-nvim
        lspkind-nvim
        luasnip
        nvim-autopairs
        nvim-cmp
        nvim-lspconfig
        snippets-nvim
        ltex_extra

        # syntax
        (nvim-treesitter.withPlugins
          (_:
            with builtins;
            filter
              (drv:
                !elem
                  drv.pname
                  ((map (v: "tree-sitter-${v}-grammar") [
                    "bash"
                    "beancount"
                    "bibtex"
                    "c-sharp"
                    "clojure"
                    "cmake"
                    "cpp"
                    "cuda"
                    "eex"
                    "elixir"
                    "erlang"
                    "fish"
                    "fortran"
                    "gdscript"
                    "heex"
                    "java"
                    "julia"
                    "kotlin"
                    "latex"
                    "nickel"
                    "nix"
                    "python"
                    "ql-dbscheme"
                    "regex"
                    "ruby"
                    "scala"
                    "smithy"
                    "tsx"
                    "typescript"
                    "zig"
                  ]) ++ [ "markdown_inline-grammar" ])
              )
              pkgs.tree-sitter.allGrammars
          )
        )
        editorconfig-vim
        gentoo-syntax
        lalrpop-vim
        vim-nix
        vim-polyglot
      ]
      ++ lib.optional (lib.elem pkgs.stdenv.hostPlatform.system pkgs.tabnine.meta.platforms) cmp-tabnine
      ;
    };
  };

  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/init.lua".source = ./init.lua;
}
