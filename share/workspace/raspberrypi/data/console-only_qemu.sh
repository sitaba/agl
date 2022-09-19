#!/bin/bash

qemu-system-aarch64 \
	-machine virt \
	-cpu cortex-a57 \
	-m 2048 \
	-serial mon:stdio \
	-global virtio-mmio.force-legacy=false \
	-drive id=disk0,file=guest_rootfs,if=none,format=raw \
	-device virtio-blk-device,drive=disk0 \
	-object rng-random,filename=/dev/urandom,id=rng0 \
	-device virtio-rng-device,rng=rng0 \
	-nographic \
	-kernel guest_kernel \
	-append 'root=/dev/vda rw mem=2048M'


