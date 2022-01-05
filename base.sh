#!/bin/bash

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

pacman -S stow grub efibootmgr base-devel linux-headers terminus-font imlib2

# grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=ArchLinux
# grub-mkconfig -o /boot/grub/grub.cfg

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

sudo -i -u lalith bash << EOF
git clone https://github.com/jordanator/dotfiles.git /home/lalith/.dotfiles
cd /home/lalith/.dotfiles && stow */

mkdir -p /home/lalith/.local/src && cd "$_"

git clone https://aur.archlinux.org/yay.git /home/lalith/.local/src/yay
git clone https://github.com/jordanator/st.git /home/lalith/.local/src/st
git clone https://github.com/jordanator/chadwm.git /home/lalith/.local/src/chadwn
git clone https://github.com/jordanator/dmenu.git /home/lalith/.local/src/dmenu
git clone https://github.com/christophgysin/pasystray.git /home/lalith/.local/src/dmenu
git clone https://github.com/neovim/neovim.git /home/lalith/.local/src/neovim

cd /home/lalith.local/src/yay; makepkg -si

yay -S - /home/lalith/pacman.list --answerdiff=None --answerclean=None --noconfirm

cd /home/lalith/.local/src/st && git checkout lalith && sudo make install
cd /home/lalith/.local/src/dmenu && sudo make clean install

cd /home/lalith/.local/src/chadwm && git checkout lalith && cd /home/lalith/.local/src/chadwm/chadwm && sudo make install
ln -s /home/lalith/.local/src/chadwm/.dwm /home/lalith

sed -i '155s/^/\/\*/' /home/lalith/.local/src/pasystray/src/ui.c
sed -i '160s/$/\*\//' /home/lalith/.local/src/pasystray/src/ui.c
cd /home/lalith/.local/src/pasystray && ./bootstrap.sh && ./configure && make && sudo make install
EOF
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

