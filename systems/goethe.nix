{ config, lib, pkgs, ... }:
{
  imports = [
    ../core

    ../hardware/rpi4.nix

    ../users/bemeurer
  ];

  console = {
    font = "ter-v28n";
    packages = with pkgs; [ terminus_font ];
  };

  environment.noXlibs = true;

  networking.wireless.iwd.enable = true;

  networking = {
    useNetworkd = lib.mkForce false;
    hostName = "goethe";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.2.1";
        prefixLength = 24;
      }];
      useDHCP = lib.mkForce false;
    };
  };

  secrets.files.ddclient-goethe = pkgs.mkSecret { file = ../secrets/ddclient-goethe.conf; };
  services.ddclient.configFile = config.files.secrets.ddclient-goethe.file;

  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      subnet 192.168.2.0 netmask 255.255.255.0 {
        authoritative;
        option routers 192.168.2.1;
        option subnet-mask 255.255.255.0;
        range 192.168.2.10 192.168.2.254;

        host foucault {
          hardware ethernet 48:2a:e3:61:39:66;
          fixed-address 192.168.2.2;
        }

        host comte {
          hardware ethernet 00:04:4b:e5:91:42;
          fixed-address 192.168.2.3;
        }

        host tis {
          hardware ethernet 00:07:48:26:4d:1d;
          fixed-address 192.168.2.4;
        }

        host aurelius {
          hardware ethernet dc:a6:32:c1:37:1b;
          fixed-address 192.168.2.5;
        }
      }
    '';
    interfaces = [ "eth0" ];
  };

  time.timeZone = "America/Los_Angeles";
}
