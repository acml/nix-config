{ pkgs, ... }: {

  programs = {

    nixvim = {
      keymaps = [
        { key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; mode = "n"; options = { desc = "Clear search highlighting"; }; }
        { key = "<Esc>"; action = "<C-\\><C-n>"; mode = "t"; options = { desc = "Exit terminal mode"; }; }
        { key = "gp"; action = "`[v`]"; options = { desc = "Reselect pasted text"; }; }

        { key = "<leader>bd"; action.__raw = "function() Snacks.bufdelete() end"; options = { desc = "Kill buffer"; }; }
        { key = "<leader>bl"; action = "<cmd>edit #<CR>"; options = { desc = "Switch to last buffer"; }; }
        { key = "<leader>`"; action = "<cmd>edit #<CR>"; options = { desc = "Switch to last buffer"; }; }
        { key = "<leader>bn"; action = "<cmd>bnext<CR>"; options = { desc = "Next buffer"; }; }
        { key = "<leader>bp"; action = "<cmd>bprevious<CR>"; options = { desc = "Previous buffer"; }; }

        { key = "<leader>fs"; action = "<cmd>update<CR>"; options = { desc = "Save buffer"; }; }
        { key = "<leader>bs"; action = "<cmd>update<CR>"; options = { desc = "Save buffer"; }; }
        { key = "<leader>bS"; action = "<cmd>wall<CR>"; options = { desc = "Save all buffers"; }; }

        { key = "<leader>gg"; action = "<cmd>Neogit cwd=%:p:h<CR>"; options = { desc = "Neogit status"; }; }
        { key = "<leader>op"; action = "<cmd>Neotree toggle<CR>"; options = { desc = "Project sidebar"; }; }
        { key = "<leader>o-"; action.__raw = "function() require('yazi').yazi() end"; options = { desc = "Directory editor"; }; }
      ];
    };
  };
}
