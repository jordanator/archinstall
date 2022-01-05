#!/usr/bin/env /bash

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "msi" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 msi.localdomain msi" >> /etc/hosts

echo "Enter root password"
passwd

pacman -S git stow grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers bluez bluez-utils alsa-utils openssh rsync os-prober ntfs-3g terminus-font imlib2

pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=ArchLinux
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -g wheel lalith
echo "Enter user password"
passwd lalith

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/lalith

# DWM Desktop application
mkdir /usr/share/xsessions/
cat > /usr/share/xsessions/chadwm.desktop <<EOF
[Desktop Entry]
Name=chadwm
Comment=dwm made beautiful
Exec=/home/lalith/.dwm/autostart
Type=Application
EOF

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer

su lalith
cd ~
git clone https://github.com/jordanator/dotfiles.git .dotfiles
cd .dotfiles && stow */

mkdir -p ~/.local/src && cd "$_"

git clone https://aur.archlinux.org/yay.git
git clone https://github.com/jordanator/st.git
git clone https://github.com/jordanator/chadwm.git
git clone https://github.com/jordanator/dmenu.git
git clone https://github.com/christophgysin/pasystray.git
git clone https://github.com/neovim/neovim.git

cd ~/.local/src/yay && makepkg -si

yay -S - ~/pacman.list --answerdiff=None --answerclean=None --noconfirm

cd ~/.local/src/st && git checkout lalith && sudo make install
cd ~/.local/src/dmenu && sudo make clean install

cd ~/.local/src/chadwm && git checkout lalith && cd ~/.local/src/chadwm/chadwm && sudo make install
ln -s ~/.local/src/chadwm/.dwm ~

sed -i '155s/^/\/\*/' ~/.local/src/pasystray/src/ui.c
sed -i '160s/$/\*\//' ~/.local/src/pasystray/src/ui.c
cd ~/.local/src/pasystray && ./bootstrap.sh && ./configure && make && sudo make install

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

