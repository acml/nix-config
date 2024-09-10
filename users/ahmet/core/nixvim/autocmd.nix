{ pkgs, ... }: {

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
          pattern = [ "help" "man" ];
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
            "netrw"
            "Jaq"
            "qf"
            "git"
            "help"
            "man"
            "lspinfo"
            "alpha"
            "lir"
            "DressingSelect"
            ""
          ];
        }
      ];
    };
  };
}
