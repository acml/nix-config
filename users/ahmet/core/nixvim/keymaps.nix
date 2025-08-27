{ pkgs, ... }:
{

  programs = {

    nixvim = {
      keymaps = [
        {
          key = "<Esc>";
          action = "<cmd>nohlsearch<CR>";
          mode = "n";
          options = {
            desc = "Clear search highlighting";
          };
        }
        {
          key = "<Esc>";
          action = "<C-\\><C-n>";
          mode = "t";
          options = {
            desc = "Exit terminal mode";
          };
        }
        {
          key = "gp";
          action = "`[v`]";
          options = {
            desc = "Reselect pasted text";
          };
        }
        {
          key = "<F8>";
          action = "<cmd>cnext<CR>";
          options = {
            desc = "next qf item";
          };
        }
        {
          key = "<F20>";
          action = "<cmd>cprevious<CR>";
          options = {
            desc = "previous qf item";
          };
        }

        {
          key = "<leader>'";
          action.__raw = "function() Snacks.picker.resume() end";
          options = {
            desc = "Resume last search";
          };
        }
        {
          key = "<leader>,";
          action.__raw = "function() Snacks.picker.buffers() end";
          options = {
            desc = "Switch buffer";
          };
        }
        {
          key = "<leader>bb";
          action.__raw = "function() Snacks.picker.buffers() end";
          options = {
            desc = "Switch buffer";
          };
        }
        {
          key = "<leader>bd";
          action.__raw = "function() Snacks.bufdelete() end";
          options = {
            desc = "Kill buffer";
          };
        }
        {
          key = "<leader>bl";
          action = "<cmd>edit #<CR>";
          options = {
            desc = "Switch to last buffer";
          };
        }
        {
          key = "<leader>`";
          action = "<cmd>edit #<CR>";
          options = {
            desc = "Switch to last buffer";
          };
        }
        {
          key = "<leader>bn";
          action = "<cmd>bnext<CR>";
          options = {
            desc = "Next buffer";
          };
        }
        {
          key = "<leader>bp";
          action = "<cmd>bprevious<CR>";
          options = {
            desc = "Previous buffer";
          };
        }

        {
          key = "<leader>fs";
          action = "<cmd>update<CR>";
          options = {
            desc = "Save buffer";
          };
        }
        {
          key = "<leader>bs";
          action = "<cmd>update<CR>";
          options = {
            desc = "Save buffer";
          };
        }
        {
          key = "<leader>bS";
          action = "<cmd>wall<CR>";
          options = {
            desc = "Save all buffers";
          };
        }

        {
          key = "<leader><leader>";
          action.__raw = "function() Snacks.picker.files() end";
          options = {
            desc = "Find file in project";
          };
        }
        {
          key = "<leader>.";
          action.__raw = "function() Snacks.picker.files({ dirs = { vim.fn.expand('%:p:h') } }) end";
          options = {
            desc = "Find file";
          };
        }
        {
          key = "<leader>ff";
          action.__raw = "function() Snacks.picker.files({ dirs = { vim.fn.expand('%:p:h') } }) end";
          options = {
            desc = "Find file";
          };
        }
        {
          key = "<leader>fr";
          action.__raw = "function() Snacks.picker.recent() end";
          options = {
            desc = "Recent files";
          };
        }
        {
          key = "<leader>hh";
          action.__raw = "function() Snacks.picker.help() end";
          options = {
            desc = "help";
          };
        }
        {
          key = "<leader>hk";
          action.__raw = "function() Snacks.picker.keymaps() end";
          options = {
            desc = "key-bindings";
          };
        }
        {
          key = "<leader>hm";
          action.__raw = "function() Snacks.picker.man() end";
          options = {
            desc = "man";
          };
        }
        {
          key = "<leader>ht";
          action.__raw = "function() Snacks.picker.colorschemes() end";
          options = {
            desc = "Change Colorscheme";
          };
        }
        {
          key = "<leader>pp";
          action.__raw = "function() Snacks.picker.projects() end";
          options = {
            desc = "Switch project";
          };
        }
        {
          key = "<leader>sb";
          action.__raw = "function() Snacks.picker.lines() end";
          options = {
            desc = "Search buffer";
          };
        }
        {
          key = "<leader>ss";
          action.__raw = "function() Snacks.picker.lines() end";
          options = {
            desc = "Search buffer";
          };
        }
        {
          key = "<leader>sd";
          action.__raw = "function() Snacks.picker.grep({ dirs = { vim.fn.expand('%:p:h') } }) end";
          options = {
            desc = "Search current directory";
          };
        } # cwd
        {
          key = "<leader>si";
          action.__raw = "function() Snacks.picker.lsp_symbols() end";
          options = {
            desc = "Jump to symbol";
          };
        }
        {
          key = "<leader>/";
          action.__raw = "function() Snacks.picker.grep() end";
          options = {
            desc = "Search project";
          };
        }
        {
          key = "<leader>*";
          action.__raw = "function() Snacks.picker.grep_word() end";
          options = {
            desc = "Search for symbol in project";
          };
        }

        {
          key = "<leader>gg";
          action = "<cmd>Neogit cwd=%:p:h<CR>";
          options = {
            desc = "Neogit status";
          };
        }
        {
          key = "<leader>op";
          action.__raw = "function() Snacks.picker.explorer() end";
          options = {
            desc = "Project sidebar";
          };
        }
        {
          key = "<leader>o-";
          action.__raw = "function() require('yazi').yazi() end";
          options = {
            desc = "Directory editor";
          };
        }
      ];
    };
  };
}
