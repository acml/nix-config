{
  services.udev.extraRules = ''
    KERNEL="hidraw*", SUBSYSTEM="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';
}
