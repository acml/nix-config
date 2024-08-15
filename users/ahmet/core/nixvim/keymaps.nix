{ pkgs, ... }: {

  programs = {

    nixvim = {
      keymaps = [
        { action = "<cmd>nohlsearch<CR><Esc>"; key = "<Esc>"; }
        { action = "<C-\\><C-n>"; key = "<Esc><Esc>"; mode = "t"; options.desc = "Exit terminal mode"; }
        { action = "<cmd>bdelete<CR>"; key = "<leader>bd"; options = { desc = "Kill buffer"; }; }
        { action = "<cmd>edit #<CR>"; key = "<leader>bl"; options = { desc = "Switch to last buffer"; }; }
        { action = "<cmd>edit #<CR>"; key = "<leader>`"; options = { desc = "Switch to last buffer"; }; }
        { action = "<cmd>bnext<CR>"; key = "<leader>bn"; options = { desc = "Next buffer"; }; }
        { action = "<cmd>bprevious<CR>"; key = "<leader>bp"; options = { desc = "Previous buffer"; }; }

        { action = "<cmd>update<CR>"; key = "<leader>fs"; options = { desc = "Save buffer"; }; }
        { action = "<cmd>update<CR>"; key = "<leader>bs"; options = { desc = "Save buffer"; }; }
        { action = "<cmd>wall<CR>"; key = "<leader>bS"; options = { desc = "Save all buffers"; }; }

        { action = "<cmd>Neogit cwd=%:p:h<CR>"; key = "<leader>gg"; options = { desc = "Neogit status"; }; }
        { action = "<cmd>Neotree toggle<CR>"; key = "<leader>op"; options = { desc = "Project sidebar"; }; }
        { action.__raw = "function() require('yazi').yazi() end"; key = "<leader>o-"; options = { desc = "Directory editor"; }; }
      ];
    };
  };
}
