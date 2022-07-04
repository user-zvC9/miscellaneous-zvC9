#!/bin/bash


# configuration
prefix="zvC9-"
VMName="testVM"
RAM_MB="2048"
VM_VGA="virtio"
cpu_count="2"
main_hdd_size_GiB="16"
swap_hdd_size_GiB="2"
## VGAs:
##none                 no graphic card
##std                  standard VGA (default)
##cirrus               Cirrus VGA
##vmware               VMWare SVGA
##xenfb                Xen paravirtualized framebuffer
##qxl                  QXL VGA
##virtio               Virtio VGA

# can skip next lines




#echo "converting vmdk to qcow2..."
#qemu-img convert -p -f vmdk -O qcow2 1.vmdk  ${prefix}base.qcow2
#chmod   -c 0440 ${prefix}base.qcow2
#sync ; sync
#echo "created image base (converted from vmdk to qcow2)"

rm -fv ${prefix}base.qcow2
rm -fv ${prefix}swap.qcow2

qemu-img create -f qcow2 ${prefix}base.qcow2 ${main_hdd_size_GiB}g
qemu-img create -f qcow2 ${prefix}swap.qcow2 ${swap_hdd_size_GiB}g

echo "created base, swap qcow2 files"

mkdir -p Snapshots
pushd Snapshots || exit 1

echo -n "creating script ${prefix}mk_current_state.bash…"
cat > ${prefix}mk_current_state.bash <<EOF
#!/bin/bash

i="\$(ls ??????-*.qcow2 | grep -P "\\\\d{6}-.*\\\\.qcow2" | sort | tail -n 1)"
rm -fv current_state.qcow2
if [ "x\$i" = "x" ] ; then
        echo not found snapshot, using base
        qemu-img create -f qcow2 -b ../${prefix}base.qcow2 -F qcow2 current_state.qcow2
else
        echo found \""\$i"\"
        qemu-img create -f qcow2 -b "\$i" -F qcow2 current_state.qcow2
fi
EOF

chmod -c 0755 ${prefix}mk_current_state.bash
./${prefix}mk_current_state.bash

echo created and run script


popd

for cdrom in yes no ; do
 for kvm in yes no ; do
  for network in yes no ; do
   for uefi in yes no ; do
    for local_time in yes no ; do
     script_name="${prefix}run-qemu-"
     
     if test "$kvm" = yes ; then
      script_name="${script_name}KVM-"
     else
      script_name="${script_name}noKVM-"
     fi
     if test "$network" = yes ; then
      script_name="${script_name}network-"
     else
      script_name="${script_name}NOnetwork-"
     fi
     if test "$cdrom" = yes ; then
      script_name="${script_name}cdrom-"
     else
      script_name="${script_name}NOcdrom-"
     fi
     if test "$uefi" = yes ; then
      script_name="${script_name}UEFI-"
     else
      script_name="${script_name}noUEFI-"
     fi
     if test "$local_time" = yes ; then
      script_name="${script_name}localtime.bash"
     else
      script_name="${script_name}UTCtime.bash"
     fi
     
     echo "creating script: $script_name"
     rm -fv $script_name
     echo -e "#!/bin/bash" >> $script_name
     echo -e "qemu-system-x86_64 \\\\" >> $script_name
     echo -e " -monitor stdio  \\\\" >> $script_name
     echo -e " -m $RAM_MB \\\\" >> $script_name
     echo -e " -drive file=Snapshots/current_state.qcow2,if=ide,media=disk,format=qcow2,cache=writethrough \\\\" >> $script_name
     echo -e " -boot order=c,menu=on \\\\" >> $script_name
     echo -e " -name "$VMName" \\\\" >> $script_name
     echo -e " -smp ${cpu_count} \\\\" >> $script_name
     echo -e " -nodefaults \\\\" >> $script_name
     echo -e " -vga $VM_VGA \\\\" >> $script_name
     echo -e " -chardev vc,id=vc0 -mon chardev=vc0 \\\\" >> $script_name
     echo -e " -usb -device usb-tablet \\\\" >> $script_name
     echo -e " -device usb-ehci,id=ehci0 \\\\" >> $script_name
     echo -e " -device usb-ehci,id=ehci1 \\\\" >> $script_name
     echo -e " -device usb-ehci,id=ehci2 \\\\" >> $script_name
     echo -e " -device usb-ehci,id=ehci3 \\\\" >> $script_name
     echo -e " -drive file=${prefix}swap.qcow2,format=qcow2,if=ide,media=disk,cache=writethrough \\\\" >> $script_name
     echo -e " -display gtk,window-close=off \\\\" >> $script_name
     echo -e " -cpu host \\\\" >> $script_name
     
     if test "$kvm" = yes ; then
      echo -e \  \\x2dmachine accel=kvm \\\\ >> $script_name
     else
      echo -e \  \\x2dmachine accel=tcg \\\\ >> $script_name
     fi
     if test "$network" = yes ; then
      echo -e \  "\\x2dnetdev user,id=usernet0,ipv6=off -device e1000,netdev=usernet0" \\\\ >> $script_name
     else
      echo -e \  \\x2dnet none \\\\ >> $script_name
     fi
     if test "$cdrom" = yes ; then
      echo -e \  \\x2ddrive file=cdrom.iso,if=ide,media=cdrom,readonly=on,format=raw \\\\ >> $script_name
     else
      echo -en
     fi
     if test "$uefi" = yes ; then
      echo -e \  "\\x2dbios /usr/share/qemu/OVMF.fd" \\\\ >> $script_name
     else
      :
     fi
     if test "$local_time" = yes ; then
      echo -e \  \\x2drtc base=localtime \\\\ >> $script_name
     else
      echo -e \  \\x2drtc base=utc \\\\ >> $script_name
     fi
     
     echo >> $script_name
     echo -e \\n\\n"echo" >> $script_name
     chmod -c 0755 $script_name
    done
   done
  done
 done
done

echo DONE

exit 0

echo "creating script ${prefix}run-qemu-no-network.bash"
cat >                 ${prefix}run-qemu-no-network.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=tcg \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -net none -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2
EOF

chmod -c 0750 ${prefix}run-qemu-no-network.bash

echo "creating script ${prefix}run-qemu-with-network.bash"
cat >                 ${prefix}run-qemu-with-network.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=tcg \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -netdev user,id=usernet0,ipv6=off -device e1000,netdev=usernet0 \
 -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2
EOF

chmod -c 0750 ${prefix}run-qemu-with-network.bash

echo "creating script ${prefix}run-qemu-KVM-no-network.bash"
cat >                 ${prefix}run-qemu-KVM-no-network.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=kvm \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -net none -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2
EOF

chmod -c 0750 ${prefix}run-qemu-KVM-no-network.bash

echo "creating script ${prefix}run-qemu-KVM-with-network.bash"
cat >                 ${prefix}run-qemu-KVM-with-network.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=kvm \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -netdev user,id=usernet0,ipv6=off -device e1000,netdev=usernet0 \
 -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2
EOF

chmod -c 0750 ${prefix}run-qemu-KVM-with-network.bash

#####################

echo "creating script ${prefix}run-qemu-no-network-with-cdrom.bash"
cat >                 ${prefix}run-qemu-no-network-with-cdrom.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=tcg \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -net none -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2 \
 -drive file=cdrom.iso,if=ide,media=cdrom,readonly=on,format=raw
EOF

chmod -c 0750 ${prefix}run-qemu-no-network-with-cdrom.bash

echo "creating script ${prefix}run-qemu-with-network-with-cdrom.bash"
cat >                 ${prefix}run-qemu-with-network-with-cdrom.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=tcg \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -netdev user,id=usernet0,ipv6=off -device e1000,netdev=usernet0 \
 -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2 \
 -drive file=cdrom.iso,if=ide,media=cdrom,readonly=on,format=raw
EOF

chmod -c 0750 ${prefix}run-qemu-with-network-with-cdrom.bash

echo "creating script ${prefix}run-qemu-KVM-no-network-with-cdrom.bash"
cat >                 ${prefix}run-qemu-KVM-no-network-with-cdrom.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=kvm \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -net none -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2 \
 -drive file=cdrom.iso,if=ide,media=cdrom,readonly=on,format=raw
EOF

chmod -c 0750 ${prefix}run-qemu-KVM-no-network-with-cdrom.bash

echo "creating script ${prefix}run-qemu-KVM-with-network-with-cdrom.bash"
cat >                 ${prefix}run-qemu-KVM-with-network-with-cdrom.bash <<EOF
#!/bin/bash -x
qemu-system-x86_64 -monitor stdio -machine accel=kvm \
 -m $RAM_MB -hda Snapshots/current_state.qcow2 -boot order=c,menu=on \
 -netdev user,id=usernet0,ipv6=off -device e1000,netdev=usernet0 \
 -rtc base=utc -name "$VMName" \
 -nodefaults -vga $VM_VGA -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet -device usb-ehci,id=ehci0 \
 -hdb ${prefix}swap.qcow2 \
 -drive file=cdrom.iso,if=ide,media=cdrom,readonly=on,format=raw
EOF

chmod -c 0750 ${prefix}run-qemu-KVM-with-network-with-cdrom.bash


echo created scripts

