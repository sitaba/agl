#!/bin/bash

if [ -z "$(which qemu-system-aarch64)" ]; then
    sudo apt install qemu-system
fi

qemu-system-aarch64 \
    -device virtio-net-device,netdev=net0,mac=52:54:00:12:35:02 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::2323-:23,tftp=/workspace/needlefish/build/virt-agl/tmp/deploy/images/virtio-aarch64 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0 \
    -drive id=disk0,file=./build/virt-agl/tmp/deploy/images/virtio-aarch64/agl-demo-platform-virtio-aarch64-20220904083238.rootfs.ext4,if=none,format=raw \
    -device virtio-blk-device,drive=disk0 \
    -global virtio-mmio.force-legacy=false \
    -device virtio-gpu-device \
    -device virtio-mouse-device \
    -device virtio-keyboard-device \
    -machine virt \
    -cpu cortex-a57  \
    -m 2048 \
    -serial mon:vc \
    -serial null \
    -kernel ./build/virt-agl/tmp/deploy/images/virtio-aarch64/Image--5.15.44+git0+947149960e_eb3df10e3f-r0-virtio-aarch64-20220904083238.bin \
    -append 'root=/dev/vda rw  mem=2048M ip=dhcp console=ttyAMA0 ' \
    -nographic


# ./build/virt-agl/tmp/work/x86_64-linux/qemu-helper-native/1.0-r1/recipe-sysroot-native/usr/bin/qemu-system-aarch64 \

# -display gtk,gl=on \
# -display gtk,show-cursor=on  \
