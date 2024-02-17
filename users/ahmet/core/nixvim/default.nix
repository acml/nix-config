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
        vim.cmd("set ignorecase")
        vim.cmd("set smartcase")

        local function bind(op, outer_opts)
          outer_opts = vim.tbl_extend("force", { noremap = true, silent = true }, outer_opts or {})

          return function(lhs, rhs, opts)
            opts = vim.tbl_extend("force", outer_opts, opts or {})
            vim.keymap.set(op, lhs, rhs, opts)
          end
        end

        -- map = bind("")
        -- nmap = bind("n", { noremap = false })
        nnoremap = bind("n")
        -- vnoremap = bind("v")
        xnoremap = bind("x")
        -- inoremap = bind("i")
        -- tnoremap = bind("t")

        -- Center buffer while navigating
        nnoremap("<C-u>", "<C-u>zz")
        nnoremap("<C-d>", "<C-d>zz")
        nnoremap("{", "{zz")
        nnoremap("}", "}zz")
        nnoremap("N", "Nzz")
        nnoremap("n", "nzz")
        nnoremap("G", "Gzz")
        nnoremap("gg", "ggzz")
        nnoremap("<C-i>", "<C-i>zz")
        nnoremap("<C-o>", "<C-o>zz")
        nnoremap("%", "%zz")
        nnoremap("*", "*zz")
        nnoremap("#", "#zz")

        -- Reselect the last visual selection
        xnoremap("<", function()
          vim.cmd("normal! <")
          vim.cmd("normal! gv")
        end)

        xnoremap(">", function()
          vim.cmd("normal! >")
          vim.cmd("normal! gv")
        end)

        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
          relculright = true,
          segments = {
            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
            { text = { "%s" }, click = "v:lua.ScSa" },
            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          },
        })

        local telescope = require("telescope")
        local lga_actions = require("telescope-live-grep-args.actions")
        
        telescope.setup {
          extensions = {
            live_grep_args = {
              auto_quoting = true, -- enable/disable auto-quoting
              -- define mappings, e.g.
              mappings = { -- extend mappings
                i = {
                  ["<C-k>"] = lga_actions.quote_prompt(),
                  ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                },
              },
              -- ... also accepts theme settings, for example:
              -- theme = "dropdown", -- use dropdown theme
              -- theme = { }, -- use own theme spec
              -- layout_config = { mirror=true }, -- mirror preview pane
            }
          }
        }

        select_dir_for_grep = function(prompt_bufnr)
          local action_state = require("telescope.actions.state")
          local fb = require("telescope").extensions.file_browser
          local lga = require("telescope").extensions.live_grep_args
          local current_line = action_state.get_current_line()

          fb.file_browser({
            files = false,
            depth = false,
            attach_mappings = function(prompt_bufnr)
              require("telescope.actions").select_default:replace(function()
                local entry_path = action_state.get_selected_entry().Path
                local dir = entry_path:is_dir() and entry_path or entry_path:parent()
                local relative = dir:make_relative(vim.fn.getcwd())
                local absolute = dir:absolute()

                lga.live_grep_args({
                  results_title = relative .. "/",
                  cwd = absolute,
                  default_text = current_line,
                })
              end)

              return true
            end,
          })
        end

        nnoremap("<leader>ff", function() require('telescope').extensions.file_browser.file_browser( { cwd = vim.fn.expand('%:p:h') } ) end, { desc = 'Find file' } )
        nnoremap("<leader>.", function() require('telescope').extensions.file_browser.file_browser( { cwd = vim.fn.expand('%:p:h') } ) end, { desc = 'Find file' } )
        nnoremap("<leader>*", function() require('telescope-live-grep-args.shortcuts').grep_word_under_cursor() end, { desc = 'Search for symbol in project' } )
        nnoremap("<leader>/", function() require('telescope').extensions.live_grep_args.live_grep_args() end, { desc = 'Search project' } )
        nnoremap("<leader>pp", function() require('telescope').extensions.projects.projects() end, { desc = 'Switch project' } )
        nnoremap("<leader>sd", function() require('telescope').extensions.live_grep_args.live_grep_args( { cwd = vim.fn.expand('%:p:h') } ) end, { desc = 'Search current directory' } )
        nnoremap("<leader>sD", function() select_dir_for_grep() end, { desc = 'Search other directory' })
        nnoremap("<leader>ss", function() require('telescope.builtin').current_buffer_fuzzy_find() end, { desc = 'Search buffer' } )
        nnoremap("<leader>sb", function() require('telescope.builtin').current_buffer_fuzzy_find() end, { desc = 'Search buffer' } )
        nnoremap("<leader>ht", function() require('telescope.builtin').colorscheme( { enable_preview = true } ) end, { desc = 'Change Colorscheme' } )

        local present, toggle_term = pcall(require, "toggleterm")
        if present then
          toggle_term.setup{
            open_mapping = "<F10>",
            start_in_insert = true,
            insert_mappings = true, -- whether or not the open mapping applies in insert mode
          }

          local Terminal  = require('toggleterm.terminal').Terminal

          local hterm = Terminal:new({ direction = "horizontal" })
          nnoremap("<leader>ot", function() hterm:toggle() end, { desc = 'Toggle terminal (horizontal)' } )

          local floaterm = Terminal:new({ direction = "float", float_opts = {border = "curved"} })
          nnoremap("<F10>", function() floaterm:toggle() end, { desc = 'Toggle terminal (floating)' } )
          nnoremap("<leader>of", function() floaterm:toggle() end, { desc = 'Toggle terminal (floating)' } )

          if vim.fn.executable "lazygit" == 1 then
            local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", float_opts = {border = "curved"} })
            nnoremap("<leader>ol", function() lazygit:toggle() end, { desc = 'lazygit' } )
          end
        end

        nnoremap("<leader>xx", function() require("trouble").toggle() end, { desc = 'toggle' } )
        nnoremap("<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = 'workspace diagnostics' } )
        nnoremap("<leader>xd", function() require("trouble").toggle("document_diagnostics") end, { desc = 'document diagnostics' } )
        nnoremap("<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = 'quickfix' } )
        nnoremap("<leader>xl", function() require("trouble").toggle("loclist") end, { desc = 'loclist' } )
        nnoremap("gR", function() require("trouble").toggle("lsp_references") end, { desc = 'lsp references' } )
      '';

      extraPackages = [ pkgs.lazygit ];
      extraPlugins = with pkgs.vimPlugins; [
        statuscol-nvim
        telescope-live-grep-args-nvim
      ];

      globals.mapleader = " ";

      keymaps = [
        { action = "<cmd>bdelete<CR>"; key = "<leader>bd"; }
        { action = "<cmd>bnext<CR>"; key = "<leader>bn"; }
        { action = "<cmd>bnext<CR>"; key = "]b"; }
        { action = "<cmd>bprevious<CR>"; key = "<leader>bp"; }
        { action = "<cmd>bprevious<CR>"; key = "[b"; }

        { action = "<cmd>update<CR>"; key = "<leader>fs"; }
        { action = "<cmd>update<CR>"; key = "<leader>bs"; }
        { action = "<cmd>wall<CR>"; key = "<leader>bS"; }

        { action = "<cmd>Neogit<CR>"; key = "<leader>gg"; }
        { action = "<cmd>Neotree toggle<CR>"; key = "<leader>op"; }
        { action = "<cmd>Oil<CR>"; key = "<leader>o-"; }
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
        # cmp-buffer.enable = true;
        # cmp-calc.enable = true;
        # cmp-clippy.enable = true;
        # cmp-cmdline.enable = true;
        # cmp-cmdline-history.enable = true;
        # cmp-conventionalcommits.enable = true;
        # cmp-dap.enable = true;
        # cmp-dictionary.enable = true;
        # cmp-digraphs.enable = true;
        # cmp-emoji.enable = true;
        # cmp-fish.enable = true;
        # cmp-fuzzy-buffer.enable = true;
        # cmp-fuzzy-path.enable = true;
        # cmp-git.enable = true;
        # cmp-latex-symbols.enable = true;
        # cmp-look.enable = true;
        # cmp-npm.enable = true;
        # cmp-nvim-lsp.enable = true;
        # cmp-nvim-lsp-document-symbol.enable = true;
        # cmp-nvim-lsp-signature-help.enable = true;
        # cmp-nvim-lua.enable = true;
        # cmp-omni.enable = true;
        # cmp-pandoc-nvim.enable = true;
        # cmp-pandoc-references.enable = true;
        # cmp-path.enable = true;
        # cmp-rg.enable = true;
        # cmp-snippy.enable = true;
        # cmp-spell.enable = true;
        # cmp-tmux.enable = true;
        # cmp-treesitter.enable = true;
        # cmp-vim-lsp.enable = true;
        # cmp-vimwiki-tags.enable = true;
        # cmp-vsnip.enable = true;
        # cmp-zsh.enable = true;
        # cmp_luasnip.enable = true;
        comment-nvim.enable = true;
        conform-nvim.enable = true;
        dap.enable = true;
        diffview.enable = true;
        # fidget.enable = true;
        flash.enable = true;
        friendly-snippets.enable = true;
        # fugitive.enable = true;
        gitsigns.enable = true;
        illuminate.enable = true;
        lastplace.enable = true;
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
            htmx.enable = false; # fails on darwin
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

        neo-tree = {
          enable = true;
          popupBorderStyle = "rounded";
          documentSymbols.followCursor = true;
          filesystem.followCurrentFile.enabled = true;
          window = {
            autoExpandWidth = true;
            mappings = { "<tab>" = { command = "toggle_node"; }; };
            position = "right";
          };
        };
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
        nvim-cmp = {
          enable = true;
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = { action = "cmp.mapping.select_prev_item()"; modes = [ "i" "s" ]; };
            "<Tab>" = { action = "cmp.mapping.select_next_item()"; modes = [ "i" "s" ]; };
          };
          snippet.expand = "luasnip";
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "nvim_lua"; }
            { name = "treesitter"; }
            { name = "buffer"; }
            { name = "cmdline"; }
            { name = "path"; }
            { name = "async_path"; }
          ];
        };
        nvim-ufo.enable = true;

        oil = {
          enable = true;
          deleteToTrash = true;
          skipConfirmForSimpleEdits = true;
        };

        project-nvim.enable = true;
        rainbow-delimiters.enable = true;
        refactoring.enable = true;
        spider.enable = true;
        spider.keymaps.motions = {
          b = "b";
          e = "e";
          ge = "ge";
          w = "w";
        };
        surround.enable = true;
        tagbar.enable = true;
        telescope = {
          enable = true;
          extensions = {
            file_browser.enable = true;
            fzf-native.enable = true;
            project-nvim.enable = true;
            ui-select.enable = true;
            undo.enable = true;
          };
          keymaps = {
            "<leader>," = "buffers";
            "<leader><leader>" = "find_files";
            "<leader>fr" = "oldfiles";
            "<leader>hk" = "keymaps";
            "<leader>'" = "resume";
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
        which-key.registrations = {
          "<leader><leader>" = "Find file in project";
          "<leader>'" = "Resume last search";
          "<leader>," = "Switch buffer";
          "<leader>b" = "+buffer";
          "<leader>bd" = "Kill buffer";
          "<leader>bn" = "Next buffer";
          "<leader>bp" = "Previous buffer";
          "<leader>bS" = "Save all buffers";
          "<leader>bs" = "Save buffer";
          "<leader>f" = "+file";
          "<leader>fr" = "Recent files";
          "<leader>fs" = "Save file";
          "<leader>g" = "+git";
          "<leader>h" = "+help";
          "<leader>hk" = "keymaps";
          "<leader>o" = "+open";
          "<leader>p" = "+project";
          "<leader>s" = "+search";
          "<leader>si" = "Jump to symbol";
          "<leader>x" = "+diagnostics";
        };
        wtf.enable = true;
      };
    };
  };
}
