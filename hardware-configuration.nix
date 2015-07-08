{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ 
    "ehci_pci"
    "ahci"
    "xhci_hcd"
    "usb_storage"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
  boot.extraModulePackages = [ ];
  services.virtualboxHost.enable = true;

  fileSystems = {
    "/" = { 
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      neededForBoot = true;
    };
    "/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];

  nix.maxJobs = 8;
}
