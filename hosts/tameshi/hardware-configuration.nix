{ lib, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-partlabel/disk-main-swap"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
