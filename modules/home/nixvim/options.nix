_: {

  programs = {

    nixvim = {

      clipboard = {
        # Select your clipboard provider according to your system:
        providers = {
          wl-copy.enable = false; # Linux wayland
          xclip.enable = true; # Linux Xorg (`xsel` also available)
          xsel.enable = true; # Linux Xorg (`xsel` also available)
        };
      };

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
        # scrolloff = 8;

        # Sets how neovim will display certain whitespace characters in the editor.
        # See `:help 'list'`
        # and `:help 'listchars'`
        list = true;
        listchars = {
          tab = "» ";
          trail = "·";
          nbsp = "␣";
        };

        cursorline = true;
        # cursorlineopt = "number";
      };
    };
  };
}
