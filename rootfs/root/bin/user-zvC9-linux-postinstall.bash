#!/bin/bash

function user-zvC9-sync () {
 #echo skipping a sync
 # user-zvC9-sync
 sync
}

function user-zvC9-error { # error code msg, error msg, error
 if [ $# -ge 2 ] ; then
  echo "$2"
  exit $1
 else
  if [ $# -ge 1 ] ; then
   echo "$1"
   exit 1
  else
   exit 1
  fi
 fi
}


function user-zvC9-isMint () {
	if grep -i "Linux Mint" /etc/os-release ; then
		echo "Detected Linux Mint system"
		sleep 3
		return 0
	else
		echo "Detected NOT Linux Mint system"
		sleep 3
		return 1
	fi
}

visudo
user-zvC9-sync

dpkg-reconfigure keyboard-configuration
user-zvC9-sync

nano /etc/default/grub
user-zvC9-sync

update-grub || user-zvC9-error 6 "seems like grub config (/etc/default/grub) is wrong, you must edit it (and then you can run this script again)"
user-zvC9-sync

if user-zvC9-isMint ; then
	mintsources
	user-zvC9-sync
fi

if user-zvC9-isMint ; then
	mint_packages="mint-meta-xfce  mint-meta-codecs"
else
	mint_packages=""
fi

apt update || user-zvC9-error 1 update
user-zvC9-sync


if user-zvC9-isMint ; then
	mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
	user-zvC9-sync
	apt update || user-zvC9-error 1 update
	mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
else
	apt dist-upgrade || user-zvC9-error 1 dist-upgrade
fi

user-zvC9-sync

# also: gocryptfs sirikali zulumount-gui zulumount-gui
apt --no-install-recommends install netdiag htop vlock pwgen screen mc gparted calc brasero xorriso k3b geany gedit mousepad pluma \
 atril evince vim aqemu qemu-system-gui gimp gimp-help-ru geeqie xsane hplip-gui g++ gcc gcc-doc build-essential grub-efi-amd64 \
 imagemagick imagemagick-doc kdenlive openshot shotcut flowblade simplescreenrecorder recordmydesktop kazam \
 vokoscreen obs-studio peek vlc mplayer kmplayer kmplot smplayer xplayer qmmp dragonplayer kaffeine pidgin gajim \
 kopete kde-telepathy evolution thunderbird  qbittorrent transmission-gtk aptitude rtorrent mktorrent deluge kget \
 ktorrent kgpg smbclient nmap nmapsi4 memtest86+ florence galculator autoconf automake libtool ninja-build \
 libtool-doc remmina remmina-plugin-nx remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-spice keepass2 \
 keepass2-doc keepassx keepassxc gdisk fdisk gparted parted powertop nethogs genisoimage audacity flac x11vnc ssvnc \
 tigervnc-viewer kwave lame lame-doc  ffmpeg ffmpeg-doc gdb hwinfo gddrescue x2vnc whois traceroute  tilda  \
 adb scrcpy fastboot grub-efi-amd64 encfs ecryptfs-utils virtualbox-qt virtualbox-guest-additions-iso \
 virtualbox-ext-pack parole ristretto pix apt-file git cmake cmake-doc cmake-qt-gui keyutils tomb seahorse \
 cryptsetup cryptsetup-bin cryptsetup-initramfs  \
 libpcre3-dev \
 guvcview cutecom minicom simple-scan links links2 lynx xarchiver p7zip-full rsync file-roller \
 gdebi lftp wget curl curlftpfs qtcreator catfish grep util-linux findutils binutils net-tools wireless-tools \
 wpasupplicant hasciicam pdfarranger pdfchain pdfsam pdfshuffler pdftk gimagereader  \
 tesseract-ocr-rus gscan2pdf quodlibet h264enc xvidenc simpleburn ogmrip ogmrip-doc ogmrip-plugins \
 ogmrip-video-copy acidrip winff handbrake gopchop dvdbackup mencoder divxenc wodim devede videotrans dvdauthor \
 dvd+rw-tools growisofs openvpn openssl squashfs-tools squashfs-tools-ng smartmontools sweeper xfce4-xkb-plugin \
 procinfo syslinux-utils xscreensaver linuxvnc  \
 nftables ftp openssh-client aria2 atftp filezilla ftp-ssl ftpcopy gftp gftp-gtk gftp-text inetutils-ftp jftp  \
 wput zftp putty-tools ncftp tftp tnftp  \
 $mint_packages  || user-zvC9-error 2 "install 1"
 
user-zvC9-sync

# for apt-file:
apt update
user-zvC9-sync


#apt purge bsd-mailx postfix
#user-zvC9-sync

# this is for qemu 7.0.0, also need glib and pixman
apt install libpcre3-dev libsdl2-dev libsdl2-image-dev libgtk3.0-cil-dev python3-sphinx  libgnutls28-dev \
	libusb-1.0-0-dev  \
        libvde-dev libvncserver-dev libvdeplug-dev libgtkmm-3.0-dev libusb-1.0-0-dev libcap-ng-dev \
        libattr1-dev python3-sphinx-rtd-theme libpcre3-dev gettext  || user-zvC9-error 3 "install 2"
user-zvC9-sync

update-alternatives --config iptables
user-zvC9-sync

apt install samba  || user-zvC9-error 4 "install 3"
systemctl stop smbd
systemctl stop nmbd
systemctl disable smbd
systemctl disable nmbd
user-zvC9-sync
 
# apt install ansible libopenusb-dev python3-sphinx-bootstrap-theme

mkdir -p /root/build/git/glib
cd /root/build/git/glib
if test "x$PWD" = "x/root/build/git/glib" ; then
 git clone https://gitlab.gnome.org/GNOME/glib.git
 user-zvC9-sync
else
 :
fi

mkdir -p /root/downloads

if test -e /root/downloads/pixman-0.40.0.tar.gz ; then
 :
else
 wget -O /root/downloads/pixman-0.40.0.tar.gz  https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
 user-zvC9-sync
fi

if test -e /root/downloads/pixman-0.40.0.tar.gz.sha512 ; then
 :
else
 wget -O /root/downloads/pixman-0.40.0.tar.gz.sha512  https://www.cairographics.org/releases/pixman-0.40.0.tar.gz.sha512
 user-zvC9-sync
fi

if test -e /root/downloads/qemu-7.0.0.tar.xz ; then
 :
else
 wget -O /root/downloads/qemu-7.0.0.tar.xz  https://download.qemu.org/qemu-7.0.0.tar.xz
 user-zvC9-sync
fi

if test -e /root/downloads/memtest86+-5.31b.bin ; then
 :
else
 wget -O /root/downloads/memtest86+-5.31b.bin  https://www.memtest.org/download/archives/5.31b/memtest86+-5.31b.bin
 user-zvC9-sync
fi

if test !  -e /root/downloads/meson-0.61.5.tar.gz ; then
 wget -O /root/downloads/meson-0.61.5.tar.gz  https://github.com/mesonbuild/meson/releases/download/0.61.5/meson-0.61.5.tar.gz
 sync  ; sync
fi


if test ! -e /root/downloads/meson-0.61.5.tar.gz.sha256sum.txt ; then
	echo "5e9a0d65c1a51936362b9686d1c5e9e184a6fd245d57e7269750ce50c20f5d9a *meson-0.61.5.tar.gz" > /root/downloads/meson-0.61.5.tar.gz.sha256sum.txt
fi

if test ! -e /root/downloads/memtest86+-5.31b.bin.sha256sum.txt ; then
	echo "7bd0940333d276a1731e21f5e2be18bf3d8b5e61b4a42ea15cdfeba64b21a554 *memtest86+-5.31b.bin" > /root/downloads/memtest86+-5.31b.bin.sha256sum.txt
fi

if test ! -e /root/downloads/qemu-7.0.0.tar.xz.sha256sum.txt ; then
	echo "f6b375c7951f728402798b0baabb2d86478ca53d44cedbefabbe1c46bf46f839 *qemu-7.0.0.tar.xz" > /root/downloads/qemu-7.0.0.tar.xz.sha256sum.txt
fi

if test ! -e /root/downloads/qemu-7.0.0.tar.xz.sha256sum.txt ; then
	echo "f6b375c7951f728402798b0baabb2d86478ca53d44cedbefabbe1c46bf46f839 *qemu-7.0.0.tar.xz" > /root/downloads/qemu-7.0.0.tar.xz.sha256sum.txt
fi

user-zvC9-sync

apt --download-only install openssh-server apache2 libapache2-mod-php php \
  php-xml php-mysql mariadb-server vsftpd samba sympathy isc-dhcp-server \
  bind9 bind9-dnsutils bind9-utils bind9-host bind9-doc bsd-mailx postfix \
  tftpd lxc lxc-utils uget dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-pgsql \
  gocryptfs sirikali zulumount-gui zulumount-gui zulucrypt-cli zulucrypt-gui zulupolkit \
  zulusafe-cli vtun sshpass seccure scrypt quicktun patator john openssh-sftp-server  || user-zvC9-error 5 "apt: download packages"
# also: novnc 
user-zvC9-sync

