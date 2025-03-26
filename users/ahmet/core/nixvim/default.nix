{ pkgs, ... }: {

  imports = [ ./autocmd.nix ./keymaps.nix ./options.nix ];

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

      extraConfigLua = ''

        -- UFO folding
        vim.o.fillchars          = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        vim.cmd [[set signcolumn=yes]]

        local signs = { Error = "", Warn = "", Hint = "", Info = "" }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

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
        vim.keymap.set('n', '<M-h>', require('smart-splits').resize_left)
        vim.keymap.set('n', '<M-j>', require('smart-splits').resize_down)
        vim.keymap.set('n', '<M-k>', require('smart-splits').resize_up)
        vim.keymap.set('n', '<M-l>', require('smart-splits').resize_right)
        -- moving between splits
        vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
        vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
        vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
        vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
        vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)
        -- swapping buffers between windows
        -- vim.keymap.set('n', '<C-Left>', require('smart-splits').swap_buf_left)
        -- vim.keymap.set('n', '<C-Down>', require('smart-splits').swap_buf_down)
        -- vim.keymap.set('n', '<C-Up>', require('smart-splits').swap_buf_up)
        -- vim.keymap.set('n', '<C-Right>', require('smart-splits').swap_buf_right)

        vim.keymap.set('n', '[e', "<cmd>cprevious<cr>zv", { silent = true, desc = "previous qf item" })
        vim.keymap.set('n', ']e', "<cmd>cnext<cr>zv", { silent = true, desc = "next qf item" })

        vim.keymap.set('n', '[E', "<cmd>cfirst<cr>zv", { silent = true, desc = "first qf item" })
        vim.keymap.set('n', ']E', "<cmd>clast<cr>zv", { silent = true, desc = "last qf item" })

        nnoremap("<leader>ot", function() Snacks.terminal.toggle() end, { desc = 'Toggle terminal (horizontal)' } )
        nnoremap("<leader>of", function() Snacks.terminal.toggle(nil, { win = {position = "float"}} ) end, { desc = 'Toggle terminal (floating)' } )
        nnoremap("<leader>oT", function() Snacks.terminal.toggle(nil, { win = {position = "right"}} ) end, { desc = 'Toggle terminal (vertical)' } )

        nnoremap("<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = 'Diagnostics (Trouble)' } )
        nnoremap("<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = 'Document Diagnostics (Trouble)' } )
        nnoremap("<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = 'Quickfix List (Trouble)' } )
        nnoremap("<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = 'Symbols (Trouble)' } )
        nnoremap("<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = 'Location List (Trouble)' } )
        nnoremap("gl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = 'LSP Definitions / references / ... (Trouble)' } )

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

          vim.api.nvim_set_keymap('n', '<leader>om', '<cmd>lua MiniMap.toggle()<CR>', {noremap = true, silent = true, desc = "Toggle minimap"})
          vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
          vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "Jump to definition" })
          vim.keymap.set("n", "<leader>cD", vim.lsp.buf.references, { desc = "Jump to references" })
          -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
          vim.keymap.set("n", "<leader>ca", '<cmd>Lspsaga code_action<cr>', { desc = "LSP Execute code action" })
        end

        require('nvim-biscuits').setup({
          default_config = {
            min_distance = 6,
            prefix_string = " ¤ "
          },
          language_config = {
            nix = { disabled = true }
          }
        })

        require('go').setup()
      '';

      extraLuaPackages = ps: [ ps.magick ];
      extraPackages = with pkgs;
        [ imagemagick universal-ctags ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          # wl-clipboard
          xclip
          xsel
        ];

      extraPlugins = with pkgs.vimPlugins; [ vim-plugin-AnsiEsc go-nvim nvim-biscuits ];

      globals.mapleader = " ";

      # performance = {
      #   byteCompileLua = {
      #     enable = true;
      #     nvimRuntime = true;
      #     plugins = true;
      #   };
      #   combinePlugins.enable = true;
      #   combinePlugins.standalonePlugins = [ "nvim-treesitter" "nvim-treesitter-textobjects" "hmts.nvim" "vimplugin-orgmode" "vimplugin-treesitter-grammar-org" "mini.nvim" ];
      # };

      plugins = {
        blink-cmp = {
          enable = true;
          settings = {
            keymap = {
              "<C-b>" = [ "scroll_documentation_up" "fallback" ];
              "<C-e>" = [ "hide" ];
              "<C-f>" = [ "scroll_documentation_down" "fallback" ];
              "<C-n>" = [ "select_next" "fallback" ];
              "<C-p>" = [ "select_prev" "fallback" ];
              "<C-space>" = [ "show" "show_documentation" "hide_documentation" ];
              "<CR>" = [ "accept" "fallback" ];
              "<C-y>" = [ "select_and_accept" ];
              "<Down>" = [ "select_next" "fallback" ];
              "<S-Tab>" = [ "select_prev" "fallback" ];
              "<Tab>" = [ "select_next" "fallback" ];
              "<Up>" = [ "select_prev" "fallback" ];
            };
          };
        };
        colorizer.enable = true;
        cmake-tools.enable = true;
        compiler.enable = true;
        dap.enable = true;
        debugprint.enable = true;
        diffview.enable = true;
        direnv.enable = true;
        friendly-snippets.enable = true;
        fzf-lua = {
          enable = true;
          keymaps = {
            "<leader>'" = { action = "resume"; options = { desc = "Resume last search"; }; };
            "<leader>," = { action = "buffers"; options = { desc = "Switch buffer"; }; };
            "<leader>." = { action = "files"; options = { desc = "Find file"; }; settings = { cwd = "%:p:h"; }; };
            "<leader>/" = { action = "live_grep"; options = { desc = "Search project"; }; };
            "<leader>*" = { action = "live_grep"; options = { desc = "Search for symbol in project"; }; settings = { search.__raw = "vim.fn.expand('<cword>')"; }; };
            "<leader><leader>" = { action = "files"; options = { desc = "Find file in project"; }; };
            "<leader>bb" = { action = "buffers"; options = { desc = "Switch buffer"; }; };
            "<leader>ff" = { action = "files"; options = { desc = "Find file"; }; settings = { cwd = "%:p:h"; }; };
            "<leader>fr" = { action = "oldfiles"; options = { desc = "Recent files"; }; };
            "<leader>hh" = { action = "help_tags"; options = { desc = "help"; }; };
            "<leader>hk" = { action = "keymaps"; options = { desc = "key-bindings"; }; };
            "<leader>hm" = { action = "man_pages"; options = { desc = "man"; }; };
            "<leader>ht" = { action = "colorschemes"; options = { desc = "Change Colorscheme"; }; };
            # "<leader>pp" = {
            #   action = "projects";
            #   options = { desc = "Switch project"; };
            # };
            "<leader>sb" = { action = "blines"; options = { desc = "Search buffer"; }; };
            "<leader>sd" = { action = "live_grep"; options = { desc = "Search current directory"; }; settings = { cwd = "%:p:h"; }; };
            "<leader>si" = { action = "lsp_document_symbols"; options = { desc = "Jump to symbol"; }; };
            "<leader>ss" = { action = "lgrep_curbuf"; options = { desc = "Search buffer"; }; };
            "<leader>sS" = { action = "lgrep_curbuf"; options = { desc = "Search buffer for thing at point"; }; settings = { search.__raw = "vim.fn.expand('<cword>')"; }; };
          };
          settings = {
            oldfiles = { include_current_session = true; };
            previewers = { builtin = { syntax_limit_b = 1024 * 100; }; };
            grep = {
              rg_glob = true;
              rg_glob_fn.__raw = ''
                function(query, opts)
                  local regex, flags = query:match("^(.-)%s%-%-(.*)$")
                  return (regex or query), flags
                end
              '';
            };
            keymap = { fzf = { "ctrl-q" = "select-all+accept"; }; };
          };
        };
        git-conflict.enable = true;
        gitblame.enable = true;
        gitblame.settings.virtual_text_column = 121;
        gitsigns.enable = true;
        gitsigns.settings.on_attach = # lua
          ''
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
        grug-far.enable = true;
        helpview.enable = true;
        hmts.enable = true;
        illuminate.enable = true;
        image.enable = true;
        indent-blankline = {
          enable = true;
          settings = {
            exclude = {
              buftypes = [ "terminal" "nofile" "quickfix" "prompt" ];
              filetypes = [ "lspinfo" "packer" "checkhealth" "help" "man" "neo-tree" "gitcommit" "''" ];
            };
            indent = { char = "▏"; };
            scope = {
              enabled = false;
              show_end = false;
              show_exact_scope = false;
              show_start = true;
            };
          };
        };
        lastplace.enable = true;
        lazy.enable = true;
        # lint.enable = true;
        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            ccls = {
              enable = false;
              initOptions.cache.directory = {
                __raw = ''vim.fn.expand("$HOME/.cache/ccls")'';
              };
            };
            clangd.enable = true;
            cmake.enable = true;
            dockerls.enable = true;
            gopls.enable = true;
            html.enable = true;
            htmx.enable = false; # fails on darwin
            jsonls.enable = true;
            lua_ls = {
              enable = true;
              settings.telemetry.enable = false;
            };
            marksman.enable = false;
            nil_ls = {
              enable = true;
              settings.nix.flake.autoArchive = true;
            };
            # nixd.enable = true;
            taplo.enable = true;
            ts_ls.enable = true;
          };
        };
        lsp-format.enable = true;
        lsp-format.lspServersToEnable = [ "gopls" ];
        # lsp-lines.enable = true;
        lspkind.enable = true;
        lspsaga = {
          enable = true;
          codeAction.extendGitSigns = true;
          lightbulb.sign = false;
        };
        lualine =
          let
            diff = {
              __unkeyed-1 = "diff";
              symbols = {
                added = " ";
                modified = " ";
                removed = " ";
              };
            };
            diagnostics = {
              __unkeyed-1 = "diagnostics";
              # sources = [ "nvim_lsp" ];
              symbols = {
                error = " ";
                warn = " ";
                info = " ";
                hint = " ";
              };
            };
            filename = {
              __unkeyed-1 = "filename";
              symbols = {
                modified = "";
                readonly = "";
                unnamed = "";
                newfile = "";
              };
            };
          in
          {
            enable = true;
            settings = {
              sections = {
                # lualine_a = [ "mode" ];
                lualine_b = [ "branch" diff diagnostics ];
                lualine_c = [ filename ];
                # lualine_x = [ "encoding" "fileformat" "filetype" ];
                # lualine_y = [ "progress" ];
                # lualine_z = [ "location" ];
              };
              options = {
                globalstatus = true;
                icons_enabled = true;
                ignore_focus = [ "neo-tree" "nvim-tree" "mini-files" ];
              };
            };
          };
        luasnip.enable = true;
        mini = {
          enable = true;
          mockDevIcons = true;
          modules = {
            align = { };
            bracketed = { };
            comment = {
              custom_commentstring.__raw = ''
                function()
                  return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
                end
              '';
            };
            icons = { };
            indentscope = {
              draw = {
                delay = 100;
                priority = 2;
                animation.__raw =
                  "require('mini.indentscope').gen_animation.none()";
              };
              options = { try_as_border = true; };
              symbol = "▏";
            };
            jump = { };
            map = { };
            operators = { };
            pairs = { };
            sessions = { };
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
            error = "";
            hint = "";
            info = "";
            warn = "";
          };
          documentSymbols.followCursor = true;
          filesystem = {
            bindToCwd = false;
            followCurrentFile.enabled = true;
            followCurrentFile.leaveDirsOpen = true;
            useLibuvFileWatcher = true;
          };
          popupBorderStyle = "rounded";
          sourceSelector.winbar = true;
          window = {
            autoExpandWidth = true;
            mappings = { "<tab>" = { command = "toggle_node"; }; };
            position = "right";
          };
        };
        neogit = {
          enable = true;
          settings = {
            auto_show_console_on = "error";
            console_timeout = 10000;
            disable_hint = true;
            disable_signs = false;
            graph_style = "unicode";
            integrations = { diffview = true; };
            signs.item = [ "" "" ];
            signs.section = [ "" "" ];
          };
        };
        neotest.enable = true;
        nix.enable = true;
        nix-develop.enable = true;
        noice = {
          enable = true;
          settings = {
            lsp.override = {
              "cmp.entry.get_documentation" = true;
              "vim.lsp.util.convert_input_to_markdown_lines" = true;
              "vim.lsp.util.stylize_markdown" = true;
            };
            presets = {
              bottom_search = true;
              command_palette = true;
              inc_rename = true;
              long_message_to_split = true;
              lsp_doc_border = true;
            };
          };
        };
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
        notify.settings.background_colour = "#000000";
        nvim-bqf.enable = true;
        nvim-ufo.enable = true;
        nvim-surround.enable = true;
        orgmode = {
          enable = true;
          settings = {
            org_agenda_files = [ "~/Documents/**/*" "~/my-orgs/**/*" ];
            org_default_notes_file = "~/Documents/refile.org";
          };
        };
        persistence.enable = true;
        precognition.enable = true;
        precognition.settings.startVisible = false;
        project-nvim = {
          enable = true;
          settings = {
            manual_mode = true;
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
        };
        rainbow-delimiters.enable = true;
        refactoring.enable = true;
        render-markdown.enable = true;
        rustaceanvim.enable = true;
        smart-splits.enable = true;
        snacks.enable = true;
        snacks.settings = {
          dashboard = {
            enabled = true;
            preset.header = ''
                                                                                 
                    ████ ██████           █████      ██                    
                   ███████████             █████                            
                   █████████ ███████████████████ ███   ███████████  
                  █████████  ███    █████████████ █████ ██████████████  
                 █████████ ██████████ █████████ █████ █████ ████ █████  
               ███████████ ███    ███ █████████ █████ █████ ████ █████ 
              ██████  █████████████████████ ████ █████ █████ ████ ██████
            '';
            sections.__raw = ''
              {
                { section = 'header' },
                { section = 'keys' },
                { section = 'recent_files', icon = ' ', title = 'Recent Files', indent = 2, padding = {2, 2} },
                { section = 'projects', icon = ' ', title = 'Projects', indent = 2, padding = 2 },
              }
            '';
          };
          statuscolumn = {
            left = [ "mark" "sign" ];
            right = [ "fold" "git" ];
            folds.open = true;
            folds.git_hl = true;
          };
        };
        sniprun.enable = true;
        spider.enable = true;
        spider.keymaps.motions = {
          b = "b";
          e = "e";
          ge = "ge";
          w = "w";
        };
        tagbar.enable = true;
        # tmux-navigator.enable = true;
        todo-comments.enable = true;

        treesitter = {
          enable = true;
          folding = true;
          nixvimInjections = true;
          settings = {
            indent.enable = false;
            highlight.enable = true;
          };
        };
        # treesitter-context.enable = true;
        treesitter-textobjects.enable = true;
        trim.enable = true;
        trim.settings.trim_on_write = false;
        trouble.enable = true;
        ts-comments.enable = true;
        ts-context-commentstring.enable = true;

        vim-matchup = {
          enable = true;
          treesitter.enable = true;
          treesitter.include_match_words = true;
        };
        which-key = {
          enable = true;
          settings.spec = [
            { __unkeyed-1 = "<leader>b"; desc = "+buffer"; }
            { __unkeyed-1 = "<leader>c"; desc = "+code"; }
            { __unkeyed-1 = "<leader>f"; desc = "+file"; }
            { __unkeyed-1 = "<leader>g"; desc = "+git"; }
            { __unkeyed-1 = "<leader>h"; desc = "+help"; icon = "󰋖"; }
            { __unkeyed-1 = "<leader>o"; desc = "+open"; icon = "󰌧"; }
            { __unkeyed-1 = "<leader>p"; desc = "+project"; icon = ""; }
            { __unkeyed-1 = "<leader>s"; desc = "+search"; }
            { __unkeyed-1 = "<leader>x"; desc = "+diagnostics"; }
          ];
        };
        wtf.enable = true;
        yazi = {
          enable = true;
          settings = {
            open_for_directories = true;
            enable_mouse_support = true;
            use_ya_for_events_reading = true;
            use_yazi_client_id_flag = true;

            highlight_groups = { hovered_buffer = null; };

            floating_window_scaling_factor = 0.8;
          };
        };
      };
    };
  };
}
