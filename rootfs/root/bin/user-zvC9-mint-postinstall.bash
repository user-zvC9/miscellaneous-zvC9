#!/bin/bash

apt --no-install-recommends install netdiag htop vlock pwgen screen mc gparted calc brasero xorriso k3b geany gedit mousepad pluma \
 atril evince vim aqemu gimp gimp-help-ru geeqie xsane hplip-gui g++ gcc gcc-doc build-essential grub-efi-amd64 \
 imagemagick imagemagick-doc kdenlive openshot shotcut flowblade simplescreenrecorder recordmydesktop kazam \
 vokoscreen obs-studio peek vlc mplayer kmplayer kmplot smplayer xplayer qmmp dragonplayer kaffeine pidgin gajim \
 kopete kde-telepathy evolution thunderbird  qbittorrent transmission-gtk aptitude rtorrent mktorrent deluge kget \
 ktorrent kgpg smbclient nmap nmapsi4 memtest86+ florence galculator autoconf automake libtool ninja-build \
 libtool-doc remmina remmina-plugin-nx remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-spice keepass2 \
 keepass2-doc keepassx keepassxc gdisk fdisk gparted parted powertop nethogs genisoimage audacity flac x11vnc ssvnc \
 tigervnc-viewer kwave lame lame-doc  ffmpeg ffmpeg-doc gdb hwinfo gddrescue x2vnc whois traceroute  tilda  \
 adb scrcpy fastboot grub-efi-amd64 encfs ecryptfs-utils virtualbox-qt virtualbox-guest-additions-iso \
 virtualbox-ext-pack parole ristretto pix apt-file git cmake cmake-doc cmake-qt-gui \
 libpcre3-dev \
 guvcview cutecom minicom simple-scan links links2 lynx xarchiver p7zip-full rsync file-roller \
 gdebi lftp wget curl curlftpfs qtcreator catfish grep util-linux findutils binutils net-tools wireless-tools \
 wpasupplicant hasciicam pdfarranger pdfchain pdfsam pdfshuffler pdftk gimagereader  \
 tesseract-ocr-rus gscan2pdf quodlibet h264enc xvidenc simpleburn ogmrip ogmrip-doc ogmrip-plugins \
 ogmrip-video-copy acidrip winff handbrake gopchop dvdbackup mencoder divxenc wodim devede videotrans dvdauthor \
 dvd+rw-tools growisofs openvpn openssl squashfs-tools squashfs-tools-ng smartmontools sweeper xfce4-xkb-plugin \
 procinfo syslinux-utils xscreensaver linuxvnc  \
 nftables \
 mint-meta-xfce mint-meta-codecs 
 
sync ; sync



apt purge bsd-mailx postfix
sync ; sync

# this is for qemu 7.0.0, also need glib and pixman
apt install libpcre3-dev libsdl2-dev libsdl2-image-dev libgtk3.0-cil-dev python3-sphinx  libgnutls28-dev \
	libusb-1.0-0-dev  \
        libvde-dev libvncserver-dev libvdeplug-dev libgtkmm-3.0-dev libusb-1.0-0-dev libcap-ng-dev \
        libattr1-dev python3-sphinx-rtd-theme libpcre3-dev
sync ; sync

update-alternatives --config iptables
sync ; sync

apt install samba
systemctl stop smbd
systemctl stop nmbd
systemctl disable smbd
systemctl disable nmbd
sync ; sync
 
# apt install ansible libopenusb-dev python3-sphinx-bootstrap-theme

if test -e /root/meson-0.61.5.tar.gz ; then
 :
else
 wget -O /root/meson-0.61.5.tar.gz  https://github.com/mesonbuild/meson/releases/download/0.61.5/meson-0.61.5.tar.gz
 sync  ; sync
fi

mkdir -p /root/build/git/glib
cd /root/build/git/glib
if test "x$PWD" = "x/root/build/git/glib" ; then
 git clone https://gitlab.gnome.org/GNOME/glib.git
 sync ; sync
else
 :
fi

if test -e /root/pixman-0.40.0.tar.gz ; then
 :
else
 wget -O /root/pixman-0.40.0.tar.gz  https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
 sync ; sync
fi

if test -e /root/pixman-0.40.0.tar.gz.sha512 ; then
 :
else
 wget -O /root/pixman-0.40.0.tar.gz.sha512  https://www.cairographics.org/releases/pixman-0.40.0.tar.gz.sha512
 sync ; sync
fi

if test -e /root/qemu-7.0.0.tar.xz ; then
 :
else
 wget -O /root/qemu-7.0.0.tar.xz  https://download.qemu.org/qemu-7.0.0.tar.xz
 sync ; sync
fi

apt --download-only install openssh-server apache2 libapache2-mod-php php php-xml php-mysql mariadb-server vsftpd samba sympathy
sync ; sync
