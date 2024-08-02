{ pkgs, ... }: {

  programs = {

    nixvim = {
      opts = {
        # numbering
        number = true;
        relativenumber = true;

        # indentation
        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        smartindent = true;

        # swap, backup, undo
        swapfile = false;
        backup = false;
        undofile = false;

        # search
        incsearch = true;
        hlsearch = true;

        # code folding
        foldcolumn = "1";
        foldlevel = 99;
        foldlevelstart = 99;
        foldenable = true;

        # misc
        wrap = false;
        scrolloff = 8;
        cursorline = true;
        # cursorlineopt = "number";
      };
    };
  };
}
