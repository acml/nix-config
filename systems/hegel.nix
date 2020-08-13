{ config, lib, pkgs, ... }: {
  imports = [
    ../core

    ../dev
    ../dev/stcg-gcs.nix

    ../hardware/packet-c2-large-arm.nix

    ../users/andi.nix
    ../users/bemeurer
    ../users/cloud.nix
    ../users/ekleog.nix
    ../users/nagisa.nix
    ../users/naser.nix
    ../users/ogle.nix
  ];

  fileSystems = {
    "/" = {
      label = "nixos";
      fsType = "ext4";
    };
    "/boot/efi" = {
      label = "boot";
      fsType = "vfat";
    };
  };

  networking = {
    hostName = "hegel";
    hostId = "69173f27";
    defaultGateway = {
      address = "147.75.47.53";
      interface = "bond0";
    };
    defaultGateway6 = {
      address = "2604:1380:4111:8f00::";
      interface = "bond0";
    };
    bonds.bond0 = {
      interfaces = [ "eth0" "eth1" ];
      driverOptions = {
        mode = "802.3ad";
        xmit_hash_policy = "layer3+4";
        lacp_rate = "fast";
        downdelay = "200";
        miimon = "100";
        updelay = "200";
      };
    };
    interfaces = rec {
      eth0.macAddress = "98:03:9b:68:aa:50";
      eth1.macAddress = eth0.macAddress;
      bond0 = {
        macAddress = eth0.macAddress;
        ipv4 = {
          routes = [{
            address = "10.0.0.0";
            prefixLength = 8;
            via = "10.32.82.0";
          }];
          addresses = [
            {
              address = "147.75.47.54";
              prefixLength = 30;
            }
            {
              address = "10.32.82.1";
              prefixLength = 31;
            }
          ];
        };
        ipv6.addresses = [{
          address = "2604:1380:4111:8f00::1";
          prefixLength = 127;
        }];
      };
    };
  };

  secrets.files.stcg-aarch64-builder-private = pkgs.mkSecret { file = ../secrets/stcg-aarch64-builder-nix.private; };
  environment.etc."nix/key.private".source = config.secrets.files.stcg-aarch64-builder-private.file;
  nix = {
    binaryCachePublicKeys = [ "stcg-aarch64-builder:0YU8Ce67UXPmSfZ6kDuNlnSPtf49fkmawYc0E3Qc/oY=" ];
    extraOptions = ''
      secret-key-files = /etc/nix/key.private
    '';
    trustedUsers = [ "jenkins" ];
  };

  # Causes issues with remote builders
  services.sshguard.enable = lib.mkForce false;

  time.timeZone = "America/Los_Angeles";

  users.users = {
    bemeurer.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPl71EcWLBnBErlZiERGSVz466ole9A7RI73h5DbxMDq bemeurer@stcg-aarch64-builder"
    ];
    cloud.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAzcKDwJmpQb0icJW025OJzOT1CFAsXPLFPeGwSIgc5O cloud@stcg-aarch64-builder"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMG2cf/uKaDfGCXxqhLnFBJHPLWFZz27JBktd10fUtY7 cloud@stcg-aarch64-builder"
    ];
    jenkins = {
      description = "Jenkins";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKIzdwOY15S91dJtY//IYRhBQk/mPMrOzSDDbxVj6X3R0GC5RnDSNV9U46SK1x3MoFmkZzLgO0Qv0mpyMvKyqdY="
      ];
    };
    nagisa.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2AbFIHV+041/Qg4rbdkcF7hTx2yNPOIaM+Wmx21kU5 nagisa@stcg-aarch64-builder"
    ];
    naser.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9nlQHpA7gO7SET33u6ww9wfsVHY+UbXnLHnVZrGUX0 naser@stcg-aarch64-builder"
    ];
    ogle.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAjlp78GL3B48FxvcNK/woMMe+3WfKXt7EId3N0siUZi ogle@stcg-aarch64-builder"
    ];
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPouKApFuTmz3XSadk7mZR69bOuPJK/LO+dzFJyIbwkJ packet.net superuser"
    ];
  };
}
