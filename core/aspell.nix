{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.tr
  ];

  # Configure aspell system wide
  environment.etc."aspell.conf".text = ''
    master en_US
    add-extra-dicts en-computers.rws
    add-extra-dicts tr.rws
  '';
}
