{ lib, pkgs, ... }: {
  programs = {

    nixvim = {
      enable = true;

      colorschemes = {
        catppuccin = {
          enable = true;
          dimInactive.enabled = true;
          terminalColors = true;
        };
        # gruvbox.enable = true;
        # nord.enable = true;
        # tokyonight.enable = true;
      };

      extraConfigLua = ''
        -- UFO folding
        vim.o.foldcolumn = "1" -- '0' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        vim.cmd [[set signcolumn=yes]]

        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
          relculright = true,
          segments = {
            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
            { text = { "%s" }, click = "v:lua.ScSa" },
            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          },
        })

        local present, toggle_term = pcall(require, "toggleterm")
        if present then
          toggle_term.setup{
            open_mapping = "<F10>",
            start_in_insert = true,
            insert_mappings = true, -- whether or not the open mapping applies in insert mode
          }

          local Terminal  = require('toggleterm.terminal').Terminal

          function hterm_toggle()
            local hterm = Terminal:new({ direction = "horizontal" })
            hterm:toggle()
          end
          vim.api.nvim_set_keymap("n", "<leader>ot", "<cmd>lua hterm_toggle()<CR>", {noremap = true, silent = true})

          function floaterm_toggle()
            local floaterm = Terminal:new({ direction = "float", float_opts = { border = "curved", }, float_opts = {border = "curved"} })
            floaterm:toggle()
          end
          vim.api.nvim_set_keymap("n", "<F10>", "<cmd>lua floaterm_toggle()<CR>", {noremap = true, silent = true})

          if vim.fn.executable "lazygit" == 1 then
            function lazygit_toggle()
              local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", float_opts = {border = "curved"} })
              lazygit:toggle()
            end
            vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua lazygit_toggle()<CR>", {noremap = true, silent = true})
          end
        end
      '';

      extraPackages = [ pkgs.lazygit ];
      extraPlugins = [ pkgs.vimPlugins.statuscol-nvim ];

      globals.mapleader = " ";

      keymaps = [
        { action = "<cmd>Neogit<CR>"; key = "<leader>gs"; }
        { action = "<cmd>NvimTreeToggle<CR>"; key = "<leader>op"; }
      ];

      options = {
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers

        shiftwidth = 2; # Tab width should be 2
      };

      plugins = {
        alpha.enable = true;
        alpha.theme = "startify";
        bufferline.enable = true;
        cmp-buffer.enable = true;
        cmp-calc.enable = true;
        cmp-clippy.enable = true;
        cmp-cmdline.enable = true;
        cmp-cmdline-history.enable = true;
        cmp-conventionalcommits.enable = true;
        cmp-dap.enable = true;
        cmp-dictionary.enable = true;
        cmp-digraphs.enable = true;
        cmp-emoji.enable = true;
        cmp-fish.enable = true;
        cmp-fuzzy-buffer.enable = true;
        cmp-fuzzy-path.enable = true;
        cmp-git.enable = true;
        cmp-latex-symbols.enable = true;
        cmp-look.enable = true;
        cmp-npm.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-nvim-lsp-document-symbol.enable = true;
        cmp-nvim-lsp-signature-help.enable = true;
        cmp-nvim-lua.enable = true;
        # cmp-nvim-ultisnips.enable = true;
        cmp-omni.enable = true;
        cmp-pandoc-nvim.enable = true;
        cmp-pandoc-references.enable = true;
        cmp-path.enable = true;
        cmp-rg.enable = true;
        cmp-snippy.enable = true;
        cmp-spell.enable = true;
        cmp-tabby.enable = true;
        cmp-tabnine.enable = true;
        cmp-tmux.enable = true;
        cmp-treesitter.enable = true;
        cmp-vim-lsp.enable = true;
        cmp-vimwiki-tags.enable = true;
        cmp-vsnip.enable = true;
        cmp-zsh.enable = true;
        cmp_luasnip.enable = true;
        comment-nvim.enable = true;
        conform-nvim.enable = true;
        coq-nvim.enable = true;
        coq-thirdparty.enable = true;
        dap.enable = true;
        diffview.enable = true;
        # fidget.enable = true;
        flash.enable = true;
        friendly-snippets.enable = true;
        # fugitive.enable = true;
        gitsigns.enable = true;
        illuminate.enable = true;
        lint.enable = true;
        lualine.enable = true;
        luasnip.enable = true;
        lsp = {
          enable = true;

          servers = {
            bashls.enable = true;
            # ccls.enable = true;
            clangd.enable = true;
            cmake.enable = true;
            dockerls.enable = true;
            gopls.enable = true;
            html.enable = true;
            htmx.enable = true;
            jsonls.enable = true;
            marksman.enable = true;
            nil_ls.enable = true;
            # nixd.enable = true;
            # rnix-lsp.enable = true;
            taplo.enable = true;
            tsserver.enable = true;

            lua-ls = {
              enable = true;
              settings.telemetry.enable = false;
            };
            rust-analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
          };
        };
        lsp-format.enable = true;
        lsp-lines.enable = true;
        lspkind.enable = true;
        lspsaga.enable = true;
        # lspsaga.lightbulb.sign = false;

        # marks.enable = true;

        neogit = {
          enable = true;
          disableHint = true;
          graphStyle = "unicode";
          integrations.diffview = true;
        };
        nix.enable = true;
        nix-develop.enable = true;
        noice.enable = true;
        noice.lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        notify.enable = true;

        nvim-autopairs.enable = true;
        nvim-cmp.enable = true;
        nvim-ufo.enable = true;
        nvim-tree = {
          enable = true;
          hijackCursor = true;
          updateFocusedFile.enable = true;
          view.side = "right";
        };
        oil.enable = true;

        project-nvim.enable = true;
        rainbow-delimiters.enable = true;
        refactoring.enable = true;
        spider.enable = true;
        surround.enable = true;
        tagbar.enable = true;
        telescope = {
          enable = true;
          extensions = {
            file_browser.enable = true;
            ui-select.enable = true;
            project-nvim.enable = true;
            undo.enable = true;
          };
          keymaps = {
            "<leader>/" = "live_grep";
            "<leader>," = "buffers";
            "<leader>'" = "resume";
            "<leader>ff" = "find_files";
            "<leader>fr" = "oldfiles";
            "<leader>hb" = "keymaps";
            "<leader>si" = "lsp_workspace_symbols";
          };
        };

        todo-comments.enable = true;
        toggleterm.enable = true;

        treesitter = {
          enable = true;
          folding = true;
          nixvimInjections = true;
        };
        treesitter-context.enable = true;
        treesitter-refactor.enable = true;
        treesitter-textobjects.enable = true;

        trouble.enable = true;
        ts-context-commentstring.enable = true;

        vim-matchup.enable = true;

        which-key.enable = true;
        wtf.enable = true;
      };
    };
  };
}
