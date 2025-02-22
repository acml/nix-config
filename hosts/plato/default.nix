{
  config,
  lib,
  nixos-hardware,
  pkgs,
  ...
}:
{
  imports = [
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-cpu-amd-pstate

    ../../core

    ../../hardware/efi.nix
    ../../hardware/fast-networking.nix
    ../../hardware/no-mitigations.nix
    ../../hardware/zfs.nix

    ../../services/nginx.nix
    ../../services/oauth2.nix
    ../../services/unbound.nix
    ../../services/syncthing.nix

    ../../users/bemeurer

    ./disko.nix
    ./state.nix
    ./transmission.nix
  ];

  age.secrets = {
    rootPassword.file = ./password.age;
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "sd_mod"
      ];
      systemd = {
        enable = true;
        services.rollback = {
          description = "Rollback root filesystem to a pristine state on boot";
          wantedBy = [ "initrd.target" ];
          after = [ "zfs-import-zroot.service" ];
          before = [ "sysroot.mount" ];
          path = with pkgs; [ zfs ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            zfs rollback -r zroot/local/root@blank && echo "  >> >> rollback complete << <<"
          '';
        };
      };
    };
    kernelModules = [ "kvm-amd" ];
    tmp.useTmpfs = true;
    zfs.requestEncryptionCredentials = lib.mkForce [ ];
  };

  environment.systemPackages = with pkgs; [
    dig
    smartmontools
  ];

  hardware.enableRedistributableFirmware = true;

  home-manager.verbose = true;
  home-manager.users.bemeurer = {
    imports = [
      ../../users/bemeurer/music
    ];
  };

  networking = {
    hostId = "e4c9bd10";
    hostName = "plato";
    firewall = {
      # allowedTCPPorts = [ 32400 ];
      # allowedUDPPorts = [ 32400 ];
    };
    nftables.enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      options = "-d";
    };
    settings = {
      max-substitution-jobs = 96;
      system-features = [
        "benchmark"
        "nixos-test"
        "big-parallel"
        "kvm"
        "gccarch-znver3"
      ];
    };
  };

  security = {
    acme.certs."stash.${config.networking.hostName}.meurer.org" = { };
    pam.loginLimits = [
      {
        domain = "*";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "-";
        item = "nofile";
        value = "1048576";
      }
      {
        domain = "*";
        type = "-";
        item = "nproc";
        value = "unlimited";
      }
    ];
  };

  environment.etc."fail2ban/filter.d/fwdrop.conf".text = ''
    [Definition]
    failregex = ^.*refused connection: IN=.*SRC=<ADDR> DST=.*$
    journalmatch = _TRANSPORT=kernel
  '';

  services = {
    chrony = {
      enable = true;
      servers = [
        "time.nist.gov"
        "time.cloudflare.com"
        "time.google.com"
        "tick.usnogps.navy.mil"
      ];
    };
    nginx = {
      resolver.addresses = [ "127.0.0.1:53" ];
      resolver.ipv6 = false;
      virtualHosts = {
        "stash.${config.networking.hostName}.meurer.org" = {
          useACMEHost = "stash.${config.networking.hostName}.meurer.org";
          kTLS = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9999";
            proxyWebsockets = true;
          };
        };
      };
    };
    fail2ban = {
      enable = true;
      bantime = "6min";
      ignoreIP = [
        "127.0.0.1/8"
        "100.64.0.0/10"
      ];
      banaction = "nftables[type=allports]";
      bantime-increment = {
        enable = true;
        formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        maxtime = "1week";
        rndtime = "10m";
        overalljails = true;
      };
      extraPackages = [
        pkgs.ipset
        pkgs.nftables
      ];
      jails.fwdrop.settings = {
        enabled = true;
        filter = "fwdrop";
        findtime = "1h";
        maxretry = "3";
      };
    };
    fwupd.enable = true;
    oauth2-proxy.nginx.virtualHosts."stash.${config.networking.hostName}.meurer.org" = { };
    smartd.enable = true;
    syncthing.settings.folders = {
      music = {
        devices = [
          "jung"
        ];
        path = "/mnt/music";
        type = "sendonly";
      };
      opus = {
        devices = [
          "jung"
        ];
        path = "/mnt/music-opus";
        type = "sendonly";
      };
    };
    zfs = {
      autoScrub.pools = [
        "zroot"
        "zdata"
      ];
      autoSnapshot = {
        enable = true;
        flags = "-k -p --utc";
      };
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  systemd.network.networks = {
    eth0 = {
      enable = false;
      matchConfig.MACAddress = "58:11:22:c4:49:a9";
      DHCP = "yes";
    };
    eth1 = {
      matchConfig.MACAddress = "6c:b3:11:08:50:54";
      DHCP = "ipv4";
      address = [
        "2a01:4f8:2b02:310::2/64 "
      ];
      routes = [
        { Gateway = "fe80::1"; }
      ];
    };
  };

  time.timeZone = "Etc/UTC";

  users = {
    users.root.hashedPasswordFile = config.age.secrets.rootPassword.path;
    groups.media.members = [
      "bemeurer"
      config.services.syncthing.user
    ];
  };

  virtualisation = {
    containers = {
      containersConf.settings.containers.annotations = [ "run.oci.keep_original_groups=1" ];
      storage.settings.storage = {
        driver = "zfs";
        graphroot = "/var/lib/containers/storage";
        runroot = "/run/containers/storage";
      };
    };
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      extraPackages = with pkgs; [ zfs ];
    };
  };
}
