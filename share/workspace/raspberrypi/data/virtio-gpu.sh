#!/bin/bash

SDL_VIDEODRIVER=wayland

qemu-system-aarch64 \
        --enable-kvm \
        -machine virt \
        -cpu host \
        -m 2048 \
        -serial mon:stdio \
        -global virtio-mmio.force-legacy=false \
        -drive id=disk0,file=guest_rootfs,if=none,format=raw \
        -device virtio-blk-device,drive=disk0 \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-rng-device,rng=rng0 \
        -kernel guest_kernel \
        -append 'root=/dev/vda rw mem=2048M' \
        -device virtio-gpu-gl-device -display sdl,gl=on -vga std \
        -full-screen \

        #-full-screen \
        #-rotate 90


        #-device virtio-gpu-gl-pci -display sdl,gl=on -vga virtio
        #-device virtio-gpu-gl-pci -display sdl,gl=on -vga std
        #-device virtio-gpu-gl-pci -display sdl,gl=es -vga std
        #-device virtio-vga-gl-pci -display sdl,gl=es -vga std
        #-device virtio-vga-gl -display sdl,gl=es -vga std

        #-device virtio-gpu-pci,virgl=on -display sdl,gl=es -vga std


