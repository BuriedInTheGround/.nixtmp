<!-- ltex: enabled=true -->

# NixOS System Configurations

[![NixOS 24.05](https://img.shields.io/badge/NixOS-24.05-blue?logo=NixOS&logoColor=white)](https://nixos.org/)

My [NixOS](https://nixos.org) system configurations.
Powered by [Nix](https://github.com/NixOS/nix),
[Flakes](https://wiki.nixos.org/wiki/Flakes),
[Home Manager](https://github.com/nix-community/home-manager),
and [passion](https://www.dictionary.com/browse/passion).

## Installation

The following steps are for installing an existing configuration. To create a
new configuration, see below.

### Step 1: Preparation

1. Download the NixOS ISO image from the [NixOS download page](https://nixos.org/download/#nixos-iso).
2. Create a bootable USB drive [following the instructions](https://nixos.org/manual/nixos/stable/#sec-booting-from-usb) you find in the NixOS manual.
3. Boot the machine from this USB drive.
4. Configure the network to connect to the Internet.
5. If you chose a graphical installation ISO image, close the installer.
6. Open a terminal.

### Step 2: Download the [disko](https://github.com/nix-community/disko) configuration

1. Select the desired configuration (see [flake.nix](./flake.nix)).
2. Run the following command, replacing `<YOUR_HOST>` as appropriate.

```shell
curl -sL https://raw.githubusercontent.com/BuriedInTheGround/.nixtmp/refs/heads/main/hosts/<YOUR_HOST>/disko-config.nix -o /tmp/disko-config.nix
```

### Step 3: Locate the installation disk

Run the following command to locate the installation disk path. It should be something like `/dev/sdX`.

```shell
lsblk -p
```

### Step 4: Run disko

Run the following command, replacing `<YOUR_DISK>` as appropriate, to partition, format and mount the installation disk.

> [!WARNING]
> This will erase any existing data on the selected installation disk.

```shell
sudo nix --experimental-features "nix-command flakes" \
     run github:nix-community/disko -- --mode disko \
     --argstr device '<YOUR_DISK>' /tmp/disko-config.nix
```

### Step 5: Check the mounted partitions

Run the following command to verify that everything went well in the previous step.

```shell
mount | grep /mnt
```

### Step 6: Generate the default NixOS configuration

Run the following to generate the default NixOS configuration.

```shell
sudo nixos-generate-config --no-filesystems --root /mnt
```

### Step 7: Download this flake

Run the following command to download and unpack this flake.

```shell
curl -sL https://github.com/BuriedInTheGround/.nixtmp/archive/main.tar.gz | sudo tar zx --directory=/mnt/etc
```

### Step 8: Update the hardware configuration

Run the following command, replacing `<YOUR_HOST>` as appropriate, to update the hardware configuration of the host included in the flake with the newly generated one.

```shell
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/.nixtmp-main/hosts/<YOUR_HOST>/hardware-configuration.nix
```

### Step 9: Update the host configuration (optional)

Run the following command, replacing `<YOUR_HOST>` as appropriate, and edit the host configuration included in the flake.

```shell
sudo vim /mnt/etc/.nixtmp-main/hosts/<YOUR_HOST>/default.nix
```

### Step 10: Install NixOS

Run the following command, replacing `<YOUR_HOST>` as appropriate, to install NixOS.

```shell
sudo nixos-install --root /mnt --flake /mnt/etc/.nixtmp-main#<YOUR_HOST>
```

### Step 11: Finalize

1. Set the password for the `root` user when prompted to do so.
2. Reboot the system using the `reboot` command.
3. Log in to the user account.
4. Enjoy your system! 🌷

### Step 12: Move the configuration to a user directory (optional)

1. Run the following command to clone the Git repository of this flake.
   ```shell
   git clone https://github.com/BuriedInTheGround/.nixtmp ~/.config/nixos
   ```
2. Run the following command to copy the updated files from the `/etc` directory.
   ```shell
   cp -r /etc/.nixtmp-main/. ~/.config/nixos
   ```
3. Configure your GitHub SSH key.
4. Run the following command to change the repository remote URL to the SSH variant.
   ```shell
   git remote set-url origin git@github.com:BuriedInTheGround/.nixtmp.git
   ```
5. Commit the changes.
6. Run the following command to rebuild the system to update the default flake location.
   ```shell
   pushd ~/.config/nixos && just deploy && popd
   ```

TODO: `sudo ln -s ~/.config/nixos/flake.nix /etc/nixos/flake.nix`

## New configuration

TODO

<!-- vim: set ft=markdown: -->
