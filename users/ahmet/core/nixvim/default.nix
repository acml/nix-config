{ pkgs, ... }:
{

  imports = [
    ./autocmd.nix
    ./keymaps.nix
    ./options.nix
  ];

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
      };

      extraConfigLua = ''

        -- UFO folding
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
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
            nix = { disabled = true },
            org = { disabled = true }
          }
        })

        require('go').setup()

        local function get_main_folders(filepath)
          local file = io.open(filepath, "r")
          if not file then
            print("Could not open file: " .. filepath)
            return nil
          end

          for line in file:lines() do
            local key, value = line:match("^%s*(.-)%s*=%s*(.-)%s*$")
            if key == "mainFolders" then
              file:close()
              -- Strip surrounding double quotes if present
              value = value:match('^"(.-)"$') or value
              return value
            end
          end

          file:close()
          print("mainFolders not found in file.")
          return nil
        end

        vim.api.nvim_create_user_command("Make", function(params)
          -- Example usage
          local main_folders = get_main_folders("proj.default.ini")
          local csd = vim.fn.getcwd() .. "/" .. main_folders .. "/csd"
          print("mainFolders: " .. (main_folders or "not found"))
          print("cwd: " .. vim.fn.getcwd())

          -- local makeprg = vim.fn.getcwd() .. "/cp1200/cp1243-5_G2/csd/docker_make.sh"
          -- Insert args at the '$*' in the makeprg
          local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
          if num_subs == 0 then
            cmd = cmd .. " " .. params.args
          end
          local task = require("overseer").new_task({
            -- cmd = vim.fn.expandcmd(cmd),
            -- cmd = vim.fn.getcwd() .. "/cp1200/cp1243-5_G2/csd/docker_make.sh" .. " " .. params.args,
            -- cwd = vim.fn.getcwd() .. "/cp1200/cp1243-5_G2/csd",
            cmd = csd .. "/docker_make.sh" .. " " .. params.args,
            -- print("cmd: " .. cmd),
            -- cwd: /home/ahmet/git_pa/CP1243-5_G2
            cwd = csd,
            -- print("cwd: " .. cwd),
            components = {
              { "on_output_quickfix", open = not params.bang, open_height = 8 },
              "default",
            },
          })
          task:start()
        end, {
            desc = "Run your makeprg as an Overseer task",
            nargs = "*",
            bang = true,
        })
        vim.keymap.set({'n', 'i'}, '<F19>', "<Esc>:Make -j$(nproc) -s", { silent = false, desc = "Compile in project" })

        vim.api.nvim_create_user_command("OverseerRestartLast", function()
          local overseer = require("overseer")
          local tasks = overseer.list_tasks({ recent_first = true })
          if vim.tbl_isempty(tasks) then
            vim.notify("No tasks found", vim.log.levels.WARN)
          else
            overseer.run_action(tasks[1], "restart")
          end
        end, {})
        vim.keymap.set({'n', 'i'}, '<F7>', "<Esc>:OverseerRestartLast<CR>", { silent = false, desc = "Repeat last command" })

        -- Keybindings shared by insert mode and command mode
        -- Move by character
        vim.keymap.set({'c', 'i'}, "<C-b>", "<Left>", { noremap = true })
        vim.keymap.set({'c', 'i'}, "<C-f>", "<Right>", { noremap = true })
        -- Move by word
        vim.keymap.set({'c', 'i'}, "<M-b>", "<S-Left>", { noremap = true })
        vim.keymap.set({'c', 'i'}, "<M-f>", "<S-Right>", { noremap = true })

        -- Insert mode keybindings
        -- Move by character
        vim.keymap.set('i', "<C-n>", "<Down>", { noremap = true })
        vim.keymap.set('i', "<C-p>", "<Up>", { noremap = true })

        -- Move to line start or end
        vim.keymap.set('i', "<C-a>", "<C-o>^", { noremap = true })
        vim.keymap.set('i', "<C-e>", "<C-o>$", { noremap = true })

        -- Command mode keybindings
        -- Move to line start -- (end is predefened)
        vim.keymap.set('c', "<C-a>", "<C-b>", { noremap = true })
      '';

      extraLuaPackages = ps: [ ps.magick ];
      extraPackages =
        with pkgs;
        [
          ghostscript
          imagemagick
          mermaid-cli
          sqlite
          universal-ctags
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          # wl-clipboard
          xclip
          xsel
        ];

      extraPlugins = with pkgs.vimPlugins; [
        vim-plugin-AnsiEsc
        go-nvim
        nvim-biscuits
      ];

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
        ansiesc = {
          enable = true;
          autoLoad = true;
        };
        blink-cmp = {
          enable = true;
          settings = {
            cmdline = {
              keymap = {
                "<C-e>" = [
                  "cancel"
                  "fallback"
                ];
              };
            };
            keymap = {
              "<C-b>" = [
                "scroll_documentation_up"
                "fallback"
              ];
              "<C-e>" = [
                "hide"
                "fallback"
              ];
              "<C-f>" = [
                "scroll_documentation_down"
                "fallback"
              ];
              "<C-n>" = [
                "select_next"
                "fallback"
              ];
              "<C-p>" = [
                "select_prev"
                "fallback"
              ];
              "<C-space>" = [
                "show"
                "show_documentation"
                "hide_documentation"
              ];
              "<CR>" = [
                "accept"
                "fallback"
              ];
              "<C-y>" = [ "select_and_accept" ];
              "<Down>" = [
                "select_next"
                "fallback"
              ];
              "<S-Tab>" = [
                "select_prev"
                "fallback"
              ];
              "<Tab>" = [
                "select_next"
                "fallback"
              ];
              "<Up>" = [
                "select_prev"
                "fallback"
              ];
            };
            snippets = {
              preset = "luasnip";
            };
            sources.providers = {
              copilot = {
                async = true;
                module = "blink-copilot";
                name = "copilot";
                score_offset = 100;
                # Optional configurations
                opts = {
                  max_completions = 3;
                  max_attempts = 4;
                  kind = "Copilot";
                  debounce = 750;
                  auto_refresh = {
                    backward = true;
                    forward = true;
                  };
                };
              };
            };
            sources.default = [
              "lsp"
              "path"
              "snippets"
              "buffer"
              "copilot"
            ];
          };
        };
        blink-copilot.enable = true;
        # cmake-tools.enable = true;
        colorizer.enable = true;
        # compiler.enable = true;
        copilot-chat.enable = true;
        copilot-lua.enable = true;
        telescope.enable = true;
        # dap.enable = true;
        debugprint.enable = true;
        diffview.enable = true;
        direnv.enable = true;
        helpview.enable = true;
        hmts.enable = true;
        image.enable = true;
        indent-blankline = {
          enable = true;
          settings = {
            exclude = {
              buftypes = [
                "snacks_dashboard"
                "terminal"
                "nofile"
                "quickfix"
                "prompt"
              ];
              filetypes = [
                "lspinfo"
                "packer"
                "checkhealth"
                "help"
                "man"
                "neo-tree"
                "gitcommit"
                "''"
              ];
            };
            indent = {
              char = "▏";
            };
            scope = {
              enabled = false;
              show_end = false;
              show_exact_scope = false;
              show_start = true;
            };
          };
        };
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
              # settings.formatting.command = [ "nixpkgs-fmt" ];
              settings.nix.flake.autoArchive = true;
            };
            taplo.enable = true;
          };
        };
        lsp-format.enable = true;
        lsp-format.lspServersToEnable = [
          "gopls"
          "nil_ls"
        ];
        lspsaga = {
          enable = true;
          settings = {
            code_action.extend_git_signs = true;
            lightbulb.sign = false;
          };
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
                lualine_b = [
                  "branch"
                  diff
                  diagnostics
                ];
                lualine_c = [ filename ];
                # lualine_x = [ "encoding" "fileformat" "filetype" ];
                # lualine_y = [ "progress" ];
                # lualine_z = [ "location" ];
              };
              options = {
                globalstatus = true;
                icons_enabled = true;
                ignore_focus = [
                  "neo-tree"
                  "nvim-tree"
                  "mini-files"
                ];
              };
            };
          };
        luasnip.enable = true;
        mini = {
          enable = true;
          luaConfig.post = # lua
            ''
              require('mini.misc').setup_restore_cursor()
            '';
          mockDevIcons = true;
          modules = {
            align = { };
            basics = { };
            bracketed = { };
            comment = {
              custom_commentstring.__raw = ''
                function()
                  return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
                end
              '';
            };
            diff = {
              view = {
                style = "sign";
                signs = {
                  add = "┃";
                  change = "┃";
                  delete = "_";
                };
              };
            };
            icons = { };
            indentscope = {
              draw = {
                delay = 100;
                priority = 2;
                animation.__raw = "require('mini.indentscope').gen_animation.none()";
              };
              options = {
                try_as_border = true;
              };
              symbol = "▏";
            };
            jump = { };
            map = { };
            misc = { };
            operators = { };
            sessions = { };
            splitjoin = { };
          };
        };
        mini-pairs.enable = true;
        neogit = {
          enable = true;
          settings = {
            auto_show_console_on = "error";
            console_timeout = 10000;
            disable_hint = true;
            disable_signs = false;
            graph_style = "unicode";
            integrations = {
              diffview = true;
            };
            signs.item = [
              ""
              ""
            ];
            signs.section = [
              ""
              ""
            ];
          };
        };
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
        notify.enable = true;
        notify.settings.background_colour = "#000000";
        nvim-bqf.enable = true;
        nvim-ufo.enable = true;
        nvim-surround.enable = true;
        orgmode = {
          enable = true;
          settings = {
            org_agenda_files = [
              "~/Documents/org/**/*"
              "~/Documents/worg/**/*"
            ];
            org_default_notes_file = "~/Documents/org/notes.org";
          };
        };
        overseer.enable = true;
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
          picker = {
            enabled = true;
            db = {
              sqlite3_path = "${pkgs.sqlite.out}/lib/libsqlite3.so";
            };
            sources = {
              projects = {
                dev = [
                  "~/git_pa"
                  "~/Projects"
                  "~/Work"
                ];
                patterns = [
                  "proj.default.ini"
                  ".git"
                  "_darcs"
                  ".hg"
                  ".bzr"
                  ".svn"
                  "package.json"
                  "Makefile"
                ];
              };
              explorer.layout.layout = {
                position = "right";
              };
            };
          };
          statuscolumn = {
            left = [
              "mark"
              "sign"
            ];
            right = [
              "fold"
              "git"
            ];
            folds.open = true;
            folds.git_hl = true;
          };
        };
        spider.enable = true;
        spider.keymaps.motions = {
          b = "b";
          e = "e";
          ge = "ge";
          w = "w";
        };
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
            {
              __unkeyed-1 = "<leader>b";
              desc = "+buffer";
            }
            {
              __unkeyed-1 = "<leader>c";
              desc = "+code";
            }
            {
              __unkeyed-1 = "<leader>f";
              desc = "+file";
            }
            {
              __unkeyed-1 = "<leader>g";
              desc = "+git";
            }
            {
              __unkeyed-1 = "<leader>h";
              desc = "+help";
              icon = "󰋖";
            }
            {
              __unkeyed-1 = "<leader>o";
              desc = "+open";
              icon = "󰌧";
            }
            {
              __unkeyed-1 = "<leader>p";
              desc = "+project";
              icon = "";
            }
            {
              __unkeyed-1 = "<leader>s";
              desc = "+search";
            }
            {
              __unkeyed-1 = "<leader>x";
              desc = "+diagnostics";
            }
          ];
        };
        yazi = {
          enable = true;
          settings = {
            open_for_directories = true;
            enable_mouse_support = true;
            use_ya_for_events_reading = true;
            use_yazi_client_id_flag = true;

            highlight_groups = {
              hovered_buffer = null;
            };

            floating_window_scaling_factor = 0.8;
          };
        };
      };
    };
  };
}
