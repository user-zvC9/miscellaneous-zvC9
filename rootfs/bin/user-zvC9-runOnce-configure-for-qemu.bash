#!/bin/bash


# configuration
prefix="zvC9-"
VMName="testVM"
RAM_MB="2048"
VM_VGA="virtio"
# VGAs:
#none                 no graphic card
#std                  standard VGA (default)
#cirrus               Cirrus VGA
#vmware               VMWare SVGA
#xenfb                Xen paravirtualized framebuffer
#qxl                  QXL VGA
#virtio               Virtio VGA

# can skip next lines

#echo "converting vmdk to qcow2..."
#qemu-img convert -p -f vmdk -O qcow2 1.vmdk  ${prefix}base.qcow2
#chmod   -c 0440 ${prefix}base.qcow2
#sync ; sync
#echo "created image base (converted from vmdk to qcow2)"

qemu-img create -f qcow2 ${prefix}base.qcow2 16g
qemu-img create -f qcow2 ${prefix}swap.qcow2 2g
sync ; sync
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

chmod -c 0750 ${prefix}mk_current_state.bash
./${prefix}mk_current_state.bash

sync ; sync

echo created and run script


popd


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


sync ; sync 
echo created scripts

