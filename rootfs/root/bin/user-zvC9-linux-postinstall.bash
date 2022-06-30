#!/bin/bash

function user-zvC9-sync () {
 #echo skipping a sync
 # user-zvC9-sync
 sync
}

function user-zvC9-error { # error code msg, error msg, error
 echo -n "Error (aborting): "
 if [ $# -ge 2 ] ; then
  echo "$2"
  exit $1
 else
  if [ $# -ge 1 ] ; then
   echo "$1"
   exit 1
  else
   echo
   exit 1
  fi
 fi
}

function zvC9-user-confirms-continue-or-exit {
 echo Continue? \(Продолжить?\)
 echo -n \"y\" Enter or \"n\" Enter \("y" Enter или "n" Enter\): 
 read answer
 if test "x$answer" = "xy" ; then
  :
 else
  echo "Aborted by user (отменено пользователем)"
  exit 120
 fi
}

function user-zvC9-isMint () {
	if grep -q -i "Linux Mint" /etc/os-release ; then
		echo -e "\\n\\nDetected Linux Mint system\\n\\n"
		#sleep 3
		return 0
	else
		echo -e "\\n\\nDetected NOT Linux Mint system\\n\\n"
		#sleep 3
		return 1
	fi
}


function zvC9-adjust-etc-default-grub {
 if test -e /etc/default/grub.zvC9.bak ; then
  echo skipping /etc/default/grub adjusting \(/etc/default/grub.zvC9.bak exists\)
 else
  if cp /etc/default/grub /etc/default/grub.zvC9.bak ; then
   cat /etc/default/grub.zvC9.bak | sed -E -e "s/^(GRUB_TIMEOUT_STYLE=.*)\$/#\\1\\nGRUB_TIMEOUT_STYLE=menu/g" \
    | sed -E -e "s/^(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\")\$/#\\1\\nGRUB_CMDLINE_LINUX_DEFAULT=\"consoleblank=30\"/g" \
      > /etc/default/grub
  else
   echo error copying /etc/default/grub to /etc/default/grub.zvC9.bak
   echo Aborting /etc/default/grub adjustment
   return 1
  fi
 fi
}

visudo
user-zvC9-sync

zvC9-user-confirms-continue-or-exit

dpkg-reconfigure keyboard-configuration
user-zvC9-sync

zvC9-user-confirms-continue-or-exit

zvC9-adjust-etc-default-grub
nano /etc/default/grub
user-zvC9-sync

zvC9-user-confirms-continue-or-exit

update-grub || user-zvC9-error 6 "seems like grub config (/etc/default/grub) is wrong, you must edit it (and then you can run this script again)"
user-zvC9-sync

zvC9-user-confirms-continue-or-exit

if user-zvC9-isMint ; then
	mintsources
	user-zvC9-sync
fi

zvC9-user-confirms-continue-or-exit

if user-zvC9-isMint ; then
	mint_packages="mint-meta-xfce  mint-meta-codecs"
else
	mint_packages=""
fi

apt update || user-zvC9-error 1 update
user-zvC9-sync

zvC9-user-confirms-continue-or-exit

if user-zvC9-isMint ; then
 apt --download-only --yes dist-upgrade
 user-zvC9-sync
 
 zvC9-user-confirms-continue-or-exit
 
	mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
	user-zvC9-sync
	
	zvC9-user-confirms-continue-or-exit
	
	apt update || user-zvC9-error 1 update
	apt --download-only --yes dist-upgrade
	user-zvC9-sync
	
	zvC9-user-confirms-continue-or-exit
	
	mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
	user-zvC9-sync
	zvC9-user-confirms-continue-or-exit
else
 apt --download-only --yes dist-upgrade
 user-zvC9-sync
 zvC9-user-confirms-continue-or-exit
 
	apt dist-upgrade || user-zvC9-error 1 dist-upgrade
	user-zvC9-sync
	zvC9-user-confirms-continue-or-exit
fi



# also: gocryptfs sirikali zulumount-gui zulumount-gui
apt_pkglist="netdiag htop vlock pwgen screen tmux mc gparted calc brasero xorriso \
 k3b k3b-i18n geany gedit mousepad pluma basez \
 atril evince vim aqemu qemu-system-gui qemu-utils qemu-system-x86 qemu-system-common qemu-system-data qemu-kvm \
 ovmf \
 indent indent-doc \
 timeshift time sed rfkill mugshot germinate console-setup catfish  \
 mate-calc galculator bc dc octave qalc qalculate-gtk  \
 bash bash-completion bash-doc command-not-found  \
 zstd p7zip-full rsync openssh-client sshfs  \
 mercurial git git-man git-doc vim-doc vim nano libreoffice-writer libreoffice-draw libreoffice-calc \
 libreoffice-impress libreoffice libreoffice-l10n-ru libreoffice-help-ru tweak  \
 subversion diffutils-doc diffutils autopoint binutils \
 autoconf automake libtool bison gdb gdb-doc gdbserver valgrind \
 virt-manager virtinst   \
 rhythmbox rhythmbox-doc \
 quota reiser4progs reiserfsprogs  msr-tools lvm2 jfsutils iotop hdparm e2fsprogs efibootmgr dmsetup  dmraid dkms btrfs-progs \
 bubblewrap apt-utils f2fs-tools hwinfo gufw aptitude menulibre ifupdown exfat-fuse exfat-utils ntfs-3g dosfstools  \
 sane-utils blender dcraw dia djview4 djview3 dov4l dv4l enfuse eom exif exiv2 gocr gnuift goxel gpicview \
 graphviz  gtkmorph gwenview handbrake-cli hugin hugin-tools icoutils inkscape kino kolourpaint kruler ocrad \
 ocrmypdf okular openscad pdf2svg pdfarranger pencil2d pfsglview pfstmo pfstools pfsview photocollage photoflare \
 phototonic pixelize pixmap png23d png2html pngmeta pqiv pstoedit qiv qosmic qpdfview rawtherapee renrot rgbpaint \
 sagcad sagcad-doc sane xsane scribus showfoto solvespace scantv streamer sxiv tesseract-ocr tesseract-ocr-eng \
 tesseract-ocr-rus tgif tintii tpp ttv tupi tuxpaint unpaper uvccapture v4l-conf vamps vgrabbj viewnior \
 wings3d x264 x265 xaos xfig xcftools xine-console xine-ui xli xloadimage xmorph xpaint xzgv yagf yasw zbar-tools \
 pdf2djvu pdf2svg img2pdf k2pdfopt pod2pdf rst2pdf wkhtmltopdf   \
 iputils-arping iptables iproute2 iputils-ping iputils-tracepath isc-dhcp-client iw lftp net-tools mtr-tiny \
 network-manager openvpn tcpdump telnet whois transmission-gtk wireless-regdb wireless-tools wpasupplicant \
 nmap nmapsi4 hexchat ktorrent deluge qbittorrent nftables mktorrent ntp ntpdate putty-tools rtorrent traceroute \
 wireshark wireshark-gtk wireshark-qt wireguard wireguard-tools tinyirc tcpstat tcptrace tcptraceroute  \
 gimp gimp-help-ru geeqie xsane hplip-gui g++ gcc gcc-doc build-essential grub-efi-amd64 \
 imagemagick imagemagick-doc kdenlive openshot shotcut flowblade simplescreenrecorder recordmydesktop kazam \
 vokoscreen obs-studio peek vlc mplayer kmplayer kmplot smplayer xplayer qmmp dragonplayer kaffeine pidgin gajim \
 kopete kde-telepathy evolution thunderbird  qbittorrent transmission-gtk aptitude rtorrent mktorrent deluge kget \
 ktorrent kgpg smbclient nmap nmapsi4 memtest86+ florence  autoconf automake libtool ninja-build \
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
 wput zftp putty-tools ncftp tftp tnftp \
 libvirt-clients libvirt-daemon-driver-qemu libvirt-daemon-driver-vbox libvirt-daemon-system \
 libvirt-daemon-system-systemd libvirt-daemon libvirt-dbus libvirt-doc \
 spice-client-gtk gir1.2-spiceclientglib-2.0 gir1.2-spiceclientgtk-3.0 \
 $mint_packages"
 
apt --download-only --yes --no-install-recommends install $apt_pkglist  || user-zvC9-error 2 "install 1 --download-only"
user-zvC9-sync
zvC9-user-confirms-continue-or-exit

apt --no-install-recommends install $apt_pkglist  || user-zvC9-error 2 "install 1"
user-zvC9-sync
zvC9-user-confirms-continue-or-exit
 


systemctl  disable NetworkManager-wait-online.service
systemctl  disable network-online.target
user-zvC9-sync
zvC9-user-confirms-continue-or-exit

# for apt-file:
apt update || user-zvC9-error 2 "apt update for apt-file"
user-zvC9-sync
zvC9-user-confirms-continue-or-exit


#apt purge bsd-mailx postfix (recommended packages, they are now ignored (--no-install-recommends))
#user-zvC9-sync

# this is for qemu 7.0.0, also need glib and pixman
apt_pkglist="libpcre3-dev libsdl2-dev libsdl2-image-dev libgtk3.0-cil-dev python3-sphinx  libgnutls28-dev \
	       libusb-1.0-0-dev  \
        libvde-dev libvncserver-dev libvdeplug-dev libgtkmm-3.0-dev libusb-1.0-0-dev libcap-ng-dev \
        libattr1-dev python3-sphinx-rtd-theme libpcre3-dev gettext"
apt --download-only --yes install $apt_pkglist  || user-zvC9-error 3 "install 2 --download-only"
user-zvC9-sync
zvC9-user-confirms-continue-or-exit

apt  install $apt_pkglist  || user-zvC9-error 3 "install 2"
user-zvC9-sync
zvC9-user-confirms-continue-or-exit

update-alternatives --config iptables
user-zvC9-sync
zvC9-user-confirms-continue-or-exit

apt install samba  || user-zvC9-error 4 "install 3"
systemctl stop smbd
systemctl stop nmbd
systemctl disable smbd
systemctl disable nmbd
user-zvC9-sync
zvC9-user-confirms-continue-or-exit
 
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

apt --download-only --yes install openssh-server apache2 apache2-doc libapache2-mod-php php \
  php-xml php-mysql mariadb-server mariadb-client mysql-common \
  vsftpd samba sympathy isc-dhcp-server postgresql postgresql-client \
  bind9 bind9-dnsutils bind9-utils bind9-host bind9-doc bsd-mailx postfix \
  tftpd lxc lxc-utils uget dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-pgsql \
  gocryptfs sirikali zulumount-gui zulumount-gui zulucrypt-cli zulucrypt-gui zulupolkit \
  zulusafe-cli vtun sshpass seccure scrypt quicktun patator john openssh-sftp-server \
  pssh ssh-tools sshesame gesftpserver lxc lxc-utils photopc autossh bing zssh zsync zurl xrdp \
  xprobe xorp xorgxrdp xchat vtun vpnc vnstat vde2 tcpspy \
  libvirt-daemon-driver-lxc libvirt-daemon-driver-storage-gluster libvirt-daemon-driver-storage-rbd \
  libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-xen libvirt-daemon-system-sysv \
  spice-vdagent ansible ansible-doc ansible-lint at aide       || user-zvC9-error 5 "apt: download packages"
# also: novnc 
user-zvC9-sync
zvC9-user-confirms-continue-or-exit

hp-plugin || user-zvC9-error 8 "hp-plugin"
user-zvC9-sync

echo -e "\\n\\ndone, success"

