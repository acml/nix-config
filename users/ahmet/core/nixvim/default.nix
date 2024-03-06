{ pkgs, ... }: {
  programs = {

    nixvim = {
      enable = true;
      enableMan = true;
      viAlias = true;
      vimAlias = true;

      colorschemes = {
        catppuccin = {
          enable = true;
          dimInactive.enabled = true;
          terminalColors = true;
          integrations = {
            dap.enabled = true;
            illuminate.enabled = true;
            mini.enabled = true;
            native_lsp.enabled = true;
            telescope.enabled = true;
          };
        };
        # gruvbox.enable = true;
        # nord.enable = true;
        # tokyonight.enable = true;
      };

      extraConfigLua = ''
        vim.opt.cursorline = true
        vim.opt.cursorlineopt = "number"

        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
          relculright = true,
          segments = {
            { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
            { text = { " %s" },                 click = "v:lua.ScSa" },
            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          },
        })

        -- UFO folding
        vim.o.foldcolumn         = "1" -- '0' is not bad
        vim.o.foldlevel          = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart     = 99
        vim.o.foldenable         = true
        vim.o.fillchars          = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        vim.cmd [[set signcolumn=yes]]

        vim.cmd("set ignorecase")
        vim.cmd("set smartcase")

        vim.cmd("set title")

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
        nnoremap("{",     "{zz")
        nnoremap("}",     "}zz")
        nnoremap("N",     "Nzz")
        nnoremap("n",     "nzz")
        nnoremap("G",     "Gzz")
        nnoremap("gg",    "ggzz")
        nnoremap("<C-i>", "<C-i>zz")
        nnoremap("<C-o>", "<C-o>zz")
        nnoremap("%",     "%zz")
        nnoremap("*",     "*zz")
        nnoremap("#",     "#zz")

        -- Reselect the last visual selection
        xnoremap("<", function()
          vim.cmd("normal! <")
          vim.cmd("normal! gv")
        end)

        xnoremap(">", function()
          vim.cmd("normal! >")
          vim.cmd("normal! gv")
        end)

        vim.diagnostic.config({
          virtual_text = false
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

        nnoremap("<leader>ff", function() require('telescope').extensions.file_browser.file_browser( { cwd = vim.fn.expand('%:p:h') } ) end,     { desc = 'Find file' } )
        nnoremap("<leader>.",  function() require('telescope').extensions.file_browser.file_browser( { cwd = vim.fn.expand('%:p:h') } ) end,     { desc = 'Find file' } )
        nnoremap("<leader>*",  function() require('telescope-live-grep-args.shortcuts').grep_word_under_cursor() end,                            { desc = 'Search for symbol in project' } )
        nnoremap("<leader>/",  function() require('telescope').extensions.live_grep_args.live_grep_args() end,                                   { desc = 'Search project' } )
        nnoremap("<leader>pp", function() require('telescope').extensions.projects.projects() end,                                               { desc = 'Switch project' } )
        nnoremap("<leader>sd", function() require('telescope').extensions.live_grep_args.live_grep_args( { cwd = vim.fn.expand('%:p:h') } ) end, { desc = 'Search current directory' } )
        nnoremap("<leader>sD", function() select_dir_for_grep() end,                                                                             { desc = 'Search other directory' })
        nnoremap("<leader>ss", function() require('telescope.builtin').current_buffer_fuzzy_find() end,                                          { desc = 'Search buffer' } )
        nnoremap("<leader>sb", function() require('telescope.builtin').current_buffer_fuzzy_find() end,                                          { desc = 'Search buffer' } )
        nnoremap("<leader>hh", function() require('telescope.builtin').help_tags( ) end,                                                         { desc = 'help' } )
        nnoremap("<leader>hm", function() require('telescope.builtin').man_pages( { sections = { 'ALL' } } ) end,                                { desc = 'man' } )
        nnoremap("<leader>ht", function() require('telescope.builtin').colorscheme( { enable_preview = true } ) end,                             { desc = 'Change Colorscheme' } )

        nnoremap("<leader>ot", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = 'Toggle terminal (horizontal)' } )
        nnoremap("<leader>of", "<cmd>ToggleTerm direction=float<cr>", { desc = 'Toggle terminal (floating)' } )
        nnoremap("<leader>oT", "<cmd>ToggleTerm direction=vertical<cr>", { desc = 'Toggle terminal (vertical)' } )

        nnoremap("<leader>xx", function() require("trouble").toggle() end, { desc = 'toggle diagnostics' } )
        nnoremap("<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = 'workspace diagnostics' } )
        nnoremap("<leader>xd", function() require("trouble").toggle("document_diagnostics") end, { desc = 'document diagnostics' } )
        nnoremap("<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = 'quickfix' } )
        nnoremap("<leader>xl", function() require("trouble").toggle("loclist") end, { desc = 'loclist' } )
        nnoremap("gR", function() require("trouble").toggle("lsp_references") end, { desc = 'lsp references' } )

        local status, map = pcall(require, "mini.map")
        if status then
          map.setup {
            integrations = {
              map.gen_integration.builtin_search(),
              map.gen_integration.diagnostic(),
              map.gen_integration.gitsigns(),
            },
            symbols = {
              encode = map.gen_encode_symbols.dot("4x2"),
            },
            window = {
              side = "right",
              width = 15, -- set to 1 for a pure scrollbar :)
              winblend = 15,
              show_integration_count = false,
            },
          }

          vim.api.nvim_set_keymap('n', '<leader>om', '<cmd>lua MiniMap.toggle()<CR>', {noremap = true, silent = true})
          vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
          vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, {})
          vim.keymap.set("n", "<leader>cD", vim.lsp.buf.references, {})
          -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
          vim.keymap.set("n", "<leader>ca", '<cmd>Lspsaga code_action<cr>', {})
        end
      '';

      extraPlugins = with pkgs.vimPlugins; [
        statuscol-nvim
        telescope-live-grep-args-nvim
      ];

      globals.mapleader = " ";

      keymaps = [
        { action = "<cmd>bdelete<CR>"; key = "<leader>bd"; }
        { action = "<cmd>edit #<CR>"; key = "<leader>bl"; }
        { action = "<cmd>edit #<CR>"; key = "<leader>`"; }
        { action = "<cmd>bnext<CR>"; key = "<leader>bn"; }
        { action = "<cmd>bprevious<CR>"; key = "<leader>bp"; }

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
        alpha = {
          enable = true;
          theme = null;
          iconsEnabled = true;
          layout =
            let
              padding = val: {
                type = "padding";
                inherit val;
              };
            in
            [
              (padding 3)
              {
                opts = {
                  hl = "AlphaHeader";
                  position = "center";
                };
                type = "text";
                val = [
                  "                                                                     "
                  "       ████ ██████           █████      ██                     "
                  "      ███████████             █████                             "
                  "      █████████ ███████████████████ ███   ███████████   "
                  "     █████████  ███    █████████████ █████ ██████████████   "
                  "    █████████ ██████████ █████████ █████ █████ ████ █████   "
                  "  ███████████ ███    ███ █████████ █████ █████ ████ █████  "
                  " ██████  █████████████████████ ████ █████ █████ ████ ██████ "
                ];
              }
              (padding 2)
              {
                type = "button";
                val = "📄 New     ";
                on_press.raw = "<cmd>ene<CR>";
                opts = {
                  # hl = "comment";
                  keymap = [
                    "n"
                    "n"
                    "<cmd>:ene<CR>"
                    {
                      noremap = true;
                      silent = true;
                      nowait = true;
                    }
                  ];
                  shortcut = "n";

                  position = "center";
                  cursor = 3;
                  width = 38;
                  align_shortcut = "right";
                  hl_shortcut = "Keyword";
                };
              }
              (padding 1)
              {
                type = "button";
                val = "🌺 Recent  ";
                on_press.__raw = "require('telescope.builtin').oldfiles";
                opts = {
                  # hl = "comment";
                  keymap = [
                    "n"
                    "r"
                    "<cmd>:Telescope oldfiles<CR>"
                    {
                      noremap = true;
                      silent = true;
                      nowait = true;
                    }
                  ];
                  shortcut = "r";

                  position = "center";
                  cursor = 3;
                  width = 38;
                  align_shortcut = "right";
                  hl_shortcut = "Keyword";
                };
              }
              (padding 1)
              {
                type = "button";
                val = "💼 Projects";
                on_press.raw = "require'telescope'.extensions.projects.projects{}";
                opts = {
                  # hl = "comment";
                  keymap = [
                    "n"
                    "p"
                    "<cmd>:Telescope projects<CR>"
                    {
                      noremap = true;
                      silent = true;
                      nowait = true;
                    }
                  ];
                  shortcut = "p";

                  position = "center";
                  cursor = 3;
                  width = 38;
                  align_shortcut = "right";
                  hl_shortcut = "Keyword";
                };
              }
              (padding 1)
              {
                type = "button";
                val = "🔎 Restore";
                on_press.raw = "require('persistence').load({ last = true })";
                opts = {
                  # hl = "comment";
                  keymap = [
                    "n"
                    "s"
                    "<cmd>:lua require('persistence').load({ last = true })<CR>"
                    {
                      noremap = true;
                      silent = true;
                      nowait = true;
                    }
                  ];
                  shortcut = "s";

                  position = "center";
                  cursor = 3;
                  width = 38;
                  align_shortcut = "right";
                  hl_shortcut = "Keyword";
                };
              }
              (padding 1)
              {
                type = "button";
                val = "❌ Quit";
                on_press.__raw = "function() vim.cmd[[qa]] end";
                opts = {
                  # hl = "comment";
                  keymap = [
                    "n"
                    "q"
                    ":qa<CR>"
                    {
                      noremap = true;
                      silent = true;
                      nowait = true;
                    }
                  ];
                  shortcut = "q";

                  position = "center";
                  cursor = 3;
                  width = 38;
                  align_shortcut = "right";
                  hl_shortcut = "Keyword";
                };
              }
              # (padding 3)
              # {
              #   opts = {
              #     hl = "AlphaFooter";
              #     position = "center";
              #   };
              #
              #   type = "text";
              #   val = [
              #     "  Loaded X plugins  in Y ms  "
              #     ".............................."
              #   ];
              # }
            ];
        };
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
        # conform-nvim.enable = true;
        dap.enable = true;
        diffview.enable = true;
        direnv.enable = true;
        # fidget.enable = true;
        flash.enable = true;
        friendly-snippets.enable = true;
        # fugitive.enable = true;
        gitsigns.enable = true;
        illuminate.enable = true;
        lastplace.enable = true;
        # lint.enable = true;
        lualine.enable = true;
        lualine.globalstatus = true;
        luasnip.enable = true;
        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            clangd.enable = true;
            cmake.enable = true;
            dockerls.enable = true;
            gopls.enable = true;
            html.enable = true;
            htmx.enable = false; # fails on darwin
            jsonls.enable = true;
            lua-ls = {
              enable = true;
              settings.telemetry.enable = false;
            };
            marksman.enable = false;
            nil_ls.enable = true;
            # nixd.enable = true;
            rust-analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            taplo.enable = true;
            tsserver.enable = true;
          };
        };
        lsp-format.enable = true;
        lsp-format.lspServersToEnable = [ "gopls" "rust-analyzer" ];
        # lsp-lines.enable = true;
        lspkind.enable = true;
        lspsaga = {
          enable = true;
          lightbulb.sign = false;
          diagnostic.diagnosticOnlyCurrent = true;
        };

        mini = {
          enable = true;
          modules = {
            align = { };
            bracketed = { };
            comment = { };
            map = { };
            operators = { };
            pairs = { };
            splitjoin = { };
          };
        };

        neo-tree = {
          enable = true;
          buffers = {
            bindToCwd = false;
            followCurrentFile.enabled = true;
            followCurrentFile.leaveDirsOpen = true;
          };
          documentSymbols.followCursor = true;
          filesystem = {
            bindToCwd = false;
            followCurrentFile.enabled = true;
            followCurrentFile.leaveDirsOpen = true;
            useLibuvFileWatcher = true;
          };
          popupBorderStyle = "rounded";
          window = {
            autoExpandWidth = true;
            mappings = { "<tab>" = { command = "toggle_node"; }; };
            position = "right";
          };
        };

        neogit = {
          enable = true;
          settings = {
            disable_hint = true;
            graph_style = "unicode";
            integrations.diffview = true;
            integrations.telescope = true;
            telescope_sorter = ''require("telescope").extensions.fzf.native_fzf_sorter'';
          };
        };

        nix.enable = true;
        nix-develop.enable = true;
        noice.enable = true;
        none-ls = {
          enable = true;
          enableLspFormat = true;
          sources = {
            diagnostics = {
              deadnix.enable = true;
              gitlint.enable = true;
              golangci_lint.enable = true;
              # ltrs.enable = true;
              # luacheck.enable = true;
              # shellcheck.enable = true;
              statix.enable = true;
              # vale.enable = true;
              # write_good.enable = true;
            };
            formatting = {
              cbfmt.enable = true;
              nixpkgs_fmt.enable = true;
              stylua.enable = true;
            };
          };
        };
        notify.enable = true;

        nvim-cmp = {
          enable = true;
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = {
              action = "cmp.mapping.select_prev_item()";
              modes = [ "i" "s" ];
            };
            "<Tab>" = {
              action = "cmp.mapping.select_next_item()";
              modes = [ "i" "s" ];
            };
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
        project-nvim.patterns = [
          "proj.default.ini"
          ".git"
          "_darcs"
          ".hg"
          ".bzr"
          ".svn"
          "Makefile"
          "package.json"
        ];
        rainbow-delimiters.enable = true;
        # refactoring.enable = true;
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
            # "<leader>hm" = {
            #   action = "man_pages";
            #   desc = "man pages";
            # };
            "<leader>'" = "resume";
            "<leader>si" = "lsp_workspace_symbols";
          };
        };

        todo-comments.enable = true;
        toggleterm = {
          enable = true;
          floatOpts.border = "rounded";
          openMapping = "<F10>";
          size = ''
            function(term)
              if term.direction == "horizontal" then
                return 12
              elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
              end
            end
          '';
        };

        treesitter = {
          enable = true;
          folding = true;
          indent = true;
          nixvimInjections = true;
        };
        # treesitter-context.enable = true;
        treesitter-refactor.enable = true;
        treesitter-textobjects.enable = true;

        trouble.enable = true;
        ts-context-commentstring.enable = true;

        vim-matchup = {
          enable = true;
          enableSurround = true;
          treesitterIntegration.enable = true;
          treesitterIntegration.includeMatchWords = true;
        };
        which-key = {
          enable = true;
          registrations = {
            "<leader><leader>" = "Find file in project";
            "<leader>'" = "Resume last search";
            "<leader>`" = "Switch to last buffer";
            "<leader>," = "Switch buffer";
            "<leader>b" = "+buffer";
            "<leader>bd" = "Kill buffer";
            "<leader>bl" = "Switch to last buffer";
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
            "<leader>hm" = "man";
            "<leader>o" = "+open";
            "<leader>op" = "Project sidebar";
            "<leader>p" = "+project";
            "<leader>s" = "+search";
            "<leader>si" = "Jump to symbol";
            "<leader>x" = "+diagnostics";
          };
          window.border = "rounded";
        };
        wtf.enable = true;
      };
    };
  };
}
