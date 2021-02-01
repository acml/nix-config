self: _:
let
  terminal =
    if self.hostPlatform.system == "x86_64-linux" then
      "${self.alacritty}/bin/alacritty"
    else
      "${self.termite}/bin/termite";
in
{
  sway-launcher-desktop = self.callPackage ./sway-launcher-desktop.nix { inherit terminal; };

  emojimenu = self.callPackage ./emojimenu.nix { inherit terminal; };

  otpmenu = self.callPackage ./gopassmenu.nix {
    inherit terminal;
    name = "otpmenu";
    filter = "^(otp)/.*$";
    getter = "otp \"$name\" | cut -f 1 -d ' '";
  };

  passmenu = self.callPackage ./gopassmenu.nix {
    inherit terminal;
    name = "passmenu";
    filter = "^(misc|ssh|websites)/.*$";
    getter = "show --password \"$name\"";
  };
}
