{ pkgs, ... }:
{

  programs = {

    nixvim = {
      autoCmd = [
        # {
        #   callback = { __raw = "function() vim.defer_fn(function() vim.cmd [[set signcolumn=yes]] end, 0) end"; };
        #   event = [ "FileType" ];
        #   group = "augroup";
        #   pattern = "NeogitLogView";
        # }

        {
          command = "set noexpandtab";
          event = [ "FileType" ];
          pattern = "make";
        }

        {
          command = "wincmd L";
          desc = "Make vertical splits for help and man buffers";
          event = [ "FileType" ];
          pattern = [
            "help"
            "man"
          ];
        }

        {
          callback = {
            __raw = ''
              function()
                vim.cmd [[
                  nnoremap <silent> <buffer> q :close<CR>
                  set nobuflisted
                ]]
              end
            '';
          };
          event = [ "FileType" ];
          pattern = [
            ""
            "DressingSelect"
            "Jaq"
            "PlenaryTestPopup"
            "checkhealth"
            "git"
            "help"
            "lir"
            "lspinfo"
            "man"
            "neotest-output"
            "neotest-output-panel"
            "neotest-summary"
            "netrw"
            "qf"
            "query"
            "spectre_panel"
            "startuptime"
            "tsplayground"
          ];
        }

        {
          callback = {
            __raw = ''
              function(event)
                if event.match:match("^%w%w+://") then
                  return
                end
                local file = vim.loop.fs_realpath(event.match) or event.match
                vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
              end
            '';
          };
          desc = "Auto create dir when save file, in case some intermediate directory is missing";
          event = [ "BufWritePre" ];
        }

        {
          callback = {
            __raw = ''
              function()
                local hover_opts = {
                  focusable = false,
                  close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                  source = "always",
                }
                vim.diagnostic.open_float(nil, hover_opts)
              end
            '';
          };
          desc = "lsp show diagnostics on CursorHold";
          event = [ "CursorHold" ];
        }

        {
          callback = {
            __raw = ''
              function()
                vim.highlight.on_yank()
              end
            '';
          };
          desc = "Highlight on yank";
          event = [ "TextYankPost" ];
        }

        {
          command = "checktime";
          desc = "Check if buffers changed on editor focus";
          event = [
            "FocusGained"
            "TermClose"
            "TermLeave"
          ];
        }

        {
          event = [ "FileType" ];
          pattern = [
            "TelescopePrompt"
            "TelescopeResults"
            "Trouble"
            "alpha"
            "checkhealth"
            "dashboard"
            "snacks_dashboard"
            "fzf"
            "gitcommit"
            "help"
            "lazy"
            "lazyterm"
            "lspinfo"
            "man"
            "mason"
            "neo-tree"
            "nofile"
            "notify"
            "packer"
            "prompt"
            "quickfix"
            "terminal"
            "toggleterm"
            "trouble"
            "\'\'"
          ];
          callback = {
            __raw = ''
              function()
                vim.b.miniindentscope_disable = true
              end
            '';
          };
        }

        ## https://github.com/bjeanes/dotfiles/blob/main/packages/nvim/plugins/snacks/dashboard.nix
        {
          event = [ "User" ];
          pattern = [
            "SnacksDashboardOpened"
          ];
          callback.__raw = ''
            function()
              vim.b.miniindentscope_disable = true
            end
          '';
        }
      ];
    };
  };
}
