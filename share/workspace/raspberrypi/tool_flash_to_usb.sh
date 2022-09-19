#!/bin/bash

sddev=/dev/sdb
while [ $# != 0 ]; do
    case $1 in
	--device | -d )
	    shift
	    sddev=$1
	    shift
	    ;;
	* )
	    build_dir=$1
	    shift
	    ;;
    esac
done

if [ -z "${build_dir}" ]; then
    echo "Input one argument: build dir"
    exit 1
fi

if [ ! -e "${sddev}" ]; then
    echo "No USB device found: ${sddev}"
    exit 1
else
    echo "WARNNING: ${sddev} will be overwrriten"
    sleep 2
fi

if [ ! -d "${build_dir}" ]; then
    echo "No such dir: ${build_dir}"
    exit 1
fi

IMG_NAME=$(ls ${build_dir}/tmp/deploy/images/*/*xz | tail -n 1)
echo "[info] Image name: $IMG_NAME"
if [ ! -f "$IMG_NAME" ]; then
    echo "No such file: $IMG_NAME"
    exit 1
fi

sudo umount ${sddev}
echo "=== Copy to usb device ==="
xzcat ${IMG_NAME} | sudo dd of=${sddev} bs=4M
echo "=== Synchronization ... ==="
sync
echo "=== Finished ==="
