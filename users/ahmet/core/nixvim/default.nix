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
          settings = {
            dim_inactive.enabled = true;
            term_colors = true;
          };
        };
        # gruvbox.enable = true;
        # nord.enable = true;
        # tokyonight.enable = true;
      };

      extraConfigLua = /* lua */ ''

        vim.opt.cursorline = true
        vim.opt.cursorlineopt = "number"

        -- UFO folding
        vim.o.foldcolumn         = "1" -- '0' is not bad
        vim.o.foldlevel          = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart     = 99
        vim.o.foldenable         = true
        vim.o.fillchars          = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        vim.cmd [[set signcolumn=yes]]

        local signs = { Error = "", Warn = "", Hint = "", Info = "" }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        vim.api.nvim_create_autocmd('FileType', {
          group = augroup,
          pattern = 'NeogitLogView',
          callback = function()
            vim.defer_fn(function()
              vim.cmd [[set signcolumn=yes]]
            end, 0)
          end,
        })

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

        -- recommended mappings
        -- resizing splits
        -- these keymaps will also accept a range,
        -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
        vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
        vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
        vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
        vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)
        -- moving between splits
        vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
        vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
        vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
        vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
        vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)
        -- swapping buffers between windows
        vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
        vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
        vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
        vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)

        vim.keymap.set('n', '[e', "<cmd>cprevious<cr>zv", { silent = true, desc = "previous qf item" })
        vim.keymap.set('n', ']e', "<cmd>cnext<cr>zv", { silent = true, desc = "next qf item" })

        vim.keymap.set('n', '[E', "<cmd>cfirst<cr>zv", { silent = true, desc = "first qf item" })
        vim.keymap.set('n', ']E', "<cmd>clast<cr>zv", { silent = true, desc = "last qf item" })

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

        require('orgmode').setup({
          org_agenda_files = {'~/Documents/org/*', '~/my-orgs/**/*'},
          org_default_notes_file = '~/Documents/org/refile.org',
        })
      '';

      extraConfigVim = /* vim */ ''
        set expandtab
        autocmd FileType make set noexpandtab
      '';

      extraPackages = with pkgs; [ universal-ctags ];
      extraPlugins = with pkgs.vimPlugins; [
        orgmode
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

        { action = "<cmd>Neogit cwd=%:p:h<CR>"; key = "<leader>gg"; }
        { action = "<cmd>Neotree toggle<CR>"; key = "<leader>op"; }
        { action = "<cmd>Oil<CR>"; key = "<leader>o-"; }
      ];

      opts = {
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers

        shiftwidth = 2; # Tab width should be 2
      };

      performance.combinePlugins.enable = true;
      performance.combinePlugins.standalonePlugins = [ "nvim-treesitter-textobjects" "hmts.nvim" "vimplugin-orgmode" "vimplugin-treesitter-grammar-org" "mini.nvim" ];

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
        clangd-extensions.enable = true;
        cmp.enable = true;
        dap.enable = true;
        debugprint.enable = true;
        diffview.enable = true;
        direnv.enable = true;
        flash.enable = true;
        friendly-snippets.enable = true;
        git-conflict.enable = true;
        gitblame.enable = true;
        gitblame.virtualTextColumn = 121;
        gitsigns.enable = true;
        gitsigns.settings.on_attach = /* lua */ ''
          function(bufnr)
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']h', function()
              if vim.wo.diff then
                vim.cmd.normal({']h', bang = true})
              else
                gitsigns.nav_hunk('next')
              end
            end)

            map('n', '[h', function()
              if vim.wo.diff then
                vim.cmd.normal({'[h', bang = true})
              else
                gitsigns.nav_hunk('prev')
              end
            end)

            -- Actions
            map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = 'stage hunk' })
            map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = 'reset hunk' })
            map('v', '<leader>ghs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'stage hunk' })
            map('v', '<leader>ghr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'reset hunk' })
            map('n', '<leader>ghS', gitsigns.stage_buffer, { desc = 'stage buffer' })
            map('n', '<leader>ghu', gitsigns.undo_stage_hunk, { desc = 'undo stage hunk' })
            map('n', '<leader>ghR', gitsigns.reset_buffer, { desc = 'reset buffer' })
            map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = 'preview hunk' })
            map('n', '<leader>ghb', function() gitsigns.blame_line{full=true} end, { desc = 'blame line' })
            map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = 'toggle current line blame' })
            map('n', '<leader>ghd', gitsigns.diffthis, { desc = 'diff this' })
            map('n', '<leader>ghD', function() gitsigns.diffthis('~') end, { desc = 'diff ~' })
            map('n', '<leader>gtd', gitsigns.toggle_deleted, { desc = 'toggle deleted' })

            -- Text object
            map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          end
        '';
        hmts.enable = true;
        illuminate.enable = true;
        lastplace.enable = true;
        # lint.enable = true;
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
            nil-ls.enable = true;
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
          codeAction.extendGitSigns = true;
          lightbulb.sign = false;
          diagnostic.diagnosticOnlyCurrent = true;
        };
        lualine = {
          enable = true;
          globalstatus = true;
          ignoreFocus = [ "neo-tree" ];
        };
        luasnip.enable = true;
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
          closeIfLastWindow = true;
          defaultComponentConfigs.diagnostics.symbols = {
            error = "";
            hint = "";
            info = "";
            warn = "";
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
            console_timeout = 10000;
            disable_hint = true;
            disable_signs = true;
            graph_style = "unicode";
            integrations = {
              diffview = true;
              telescope = true;
            };
            telescope_sorter = ''require("telescope").extensions.fzf.native_fzf_sorter'';
          };
        };
        neotest.enable = true;
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
        nvim-bqf.enable = true;
        nvim-colorizer.enable = true;
        nvim-ufo.enable = true;
        oil = {
          enable = true;
          settings = {
            delete_to_trash = true;
            skip_confirm_for_simple_edits = true;
          };
        };
        project-nvim = {
          enable = true;
          enableTelescope = true;
          manualMode = true;
          patterns = [
            "proj.default.ini"
            ".git"
            "_darcs"
            ".hg"
            ".bzr"
            ".svn"
            "Makefile"
            "package.json"
          ];
        };
        rainbow-delimiters.enable = true;
        refactoring.enable = true;
        refactoring.enableTelescope = true;
        rustaceanvim.enable = true;
        smart-splits.enable = true;
        sniprun.enable = true;
        spider.enable = true;
        spider.keymaps.motions = {
          b = "b";
          e = "e";
          ge = "ge";
          w = "w";
        };
        statuscol.enable = true;
        statuscol.settings = {
          relculright = true;
          segments = [
            { click = "v:lua.ScFa"; text = [{ __raw = "require('statuscol.builtin').foldfunc"; }]; }
            { click = "v:lua.ScSa"; text = [ " %s" ]; }
            { click = "v:lua.ScLa"; text = [{ __raw = "require('statuscol.builtin').lnumfunc"; } " "]; }
          ];
        };
        surround.enable = true;
        tagbar.enable = true;
        telescope = {
          enable = true;
          extensions = {
            file-browser.enable = true;
            frecency.enable = true;
            fzf-native.enable = true;
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
            "<leader>si" = "lsp_document_symbols";
          };
        };
        # tmux-navigator.enable = true;
        todo-comments.enable = true;
        toggleterm = {
          enable = true;
          settings = {
            float_opts.border = "rounded";
            open_mapping = "[[<F10>]]";
            size = /* lua */ ''
              function(term)
                if term.direction == "horizontal" then
                  return 12
                elseif term.direction == "vertical" then
                  return vim.o.columns * 0.4
                end
              end
            '';
          };
        };

        treesitter = {
          enable = true;
          folding = true;
          nixvimInjections = true;
          settings.indent.enable = true;
        };
        # treesitter-context.enable = true;
        treesitter-textobjects.enable = true;
        trim.enable = true;
        trim.settings.trim_on_write = false;
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
