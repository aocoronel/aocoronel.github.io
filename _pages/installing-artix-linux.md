This is a personal guide to install Artix Linux

## Partitioning

```bash
# NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
# sda           8:0    0 209.0G  0 disk
# ├─sda1        8:1    0     1G  0 part  /boot
# ├─sda2        8:2    0     8G  0 part  [SWAP]
# ├─sda3        8:3    0 100.0G  0 part  /
# ├─sda4        8:4    0    70G  0 part  /home
# └─sda5        8:9    0    30G  0 part
#   └─secrets 253:0    0    30G  0 crypt /home/aoc/.secrets

cfdisk /dev/sda

# Label    -- gpt
# 1G       -- boot   sda1
# (RAM/2)G -- swap   sda2
# 70G      -- home   sda3
# 100G     -- root   sda4
# 30G      -- secret sda5

mkfs.fat -F 32 /dev/sda1

mkswap /dev/sda2
swapon /dev/sda2

mkfs.xfs /dev/sda3
mkfs.xfs /dev/sda4

cryptsetup luksFormat /dev/sda5
cryptsetup luksOpen /dev/sda5 secrets
mkfs.xfs /dev/mapper/secrets
```

## Mounting

```bash
mount /dev/sda4
mount -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

## Bootstrap

```bash
pacstrap /mnt/ "base base-devel linux linux-firmware grub efibootmgr networkmanager lvm2 cryptsetup"
genfstab -U /mnt/ >> /mnt/etc/fstab
```

## Chroot

```bash
chroot /mnt
```

## Timezone

```bash
ln -sf "/usr/share/zoneinfo/America/Sao_Paulo" /etc/localtime
hwclock --systohc
```

## Locale

```bash
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
```

## Hostname

```bash
echo "artix" > /etc/hostname
```

## User

```bash
passwd # root password
pacman -S zsh
useradd -m -G wheel -s "/bin/zsh" "aoc"
passwd aoc
```

## Sudoers

```bash
# Sudo
echo "%wheel ALL=(ALL:ALL) ALL >> /etc/sudoers
# Doas
echo "permit persist :wheel" > /etc/doas.conf
```

## Network Manager

```bash
dinitctl enable NetworkManager
```

## Grub

```bash
grub-install --efi-directory=/boot --bootloader-id=aoc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

## Pacman && Reflector

```bash
# begin /etc/pacman.d
# ParallelDownloads = 10
# ILoveCandy
# [system]
# Include = /etc/pacman.d/mirrorlist
# [world]
# Include = /etc/pacman.d/mirrorlist
# 
# [galaxy]
# Include = /etc/pacman.d/mirrorlist
# 
# #[lib32]
# #Include = /etc/pacman.d/mirrorlist
# 
# [extra]
# Include = /etc/pacman.d/mirrorlist-arch
# 
# [multilib]
# Include = /etc/pacman.d/mirrorlist-arch
# end /etc/pacman.d

pacman -Syu
pacman -S reflector
reflector -c "Brazil" -p https -f 5 -l 5 --ipv4 --ipv6 -p http -p https >>/etc/pacman.d/mirrorlist
```

## Packages

```bash
pacman -S git gcc
git clone https://github.com/aocoronel/pacmirror-config
cd pacmirror-config
cc @build && ./make
./pacmirror
```

## Reboot

```bash
exit
umount -a
reboot
```