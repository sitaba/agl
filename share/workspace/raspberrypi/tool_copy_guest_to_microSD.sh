#!/bin/bash -eu

while [ $# != 0 ]; do
    case $1 in
	--device | -d )
	    shift
	    sddev=$1
	    shift
	    echo "[info] dev: $sddev"
	    ;;
	*)
	    guest_dir=$1
	    echo "[info] guest dir: $guest_dir"
	    shift
	    ;;
    esac
done

if [ -z "$guest_dir" ]; then
    echo "Need one argument: guest build dir"
    exit
fi
if [ -z "$sddev" ]; then
    sddev=/dev/sdb
    echo "[info] dev(default): $sddev"
fi

guest_kernel_fullpath=$(readlink -e ${guest_dir}/tmp/deploy/images/*/Image)
guest_rootfs_fname=$(ls $guest_dir/tmp/deploy/images/*/ | grep -v sha256sum | grep .ext4 | tail -n 1)
guest_rootfs_fullpath=$(readlink -e $guest_dir/tmp/deploy/images/*/${guest_rootfs_fname})

echo [info] GUEST kernel path: $guest_kernel_fullpath
if [ ! -f "$guest_kernel_fullpath" ]; then echo "No such file: $guest_kernel_fullpath"; exit; fi
echo [info] GUEST rootfs path: $guest_rootfs_fullpath
if [ ! -f "$guest_rootfs_fullpath" ]; then echo "No such file: $guest_rootfs_fullpath"; exit; fi

#sudo hdparm -z $sddev
if [ ! -e "${sddev}3" ]; then
	#echo a =======
	#echo p | sudo fdisk $sddev
	#echo b =======
	#echo p | sudo fdisk $sddev | grep ${sddev}2
	#echo c =======
	#echo p | sudo fdisk $sddev | grep ${sddev}2 | awk '{ print $3 }'
	#exit
	p3_sec=$(( $(echo p | sudo fdisk $sddev | grep ${sddev}2 | awk '{ print $3 }') + 1 ))
    #echo [info] Partition begining: $p3_sec
    echo [info] Adding guest system file partition
    (
        echo         n # Add a new partition
        echo         p # Primary partition
        echo           # Partition number (Accept default: 3)
        echo ${p3_sec} # First sector
        echo    +6144M # set partition size to 6GB
        echo         w # Write changes
    ) | sudo fdisk $sddev
    #echo [info] Reread partition table
    #sudo hdparm -z $sddev
    echo [info] mkext4
    sudo mkfs.ext4 ${sddev}3
fi

echo [info] copy guest files to host rootfs
lodev=$(sudo losetup -f)
mntpt=lodev-tmp
sudo mkdir $mntpt
#sudo losetup $lodev ${sddev}3
#sudo mount $lodev $mntpt
sudo mount ${sddev}3 $mntpt
echo [info] copy guest kernel: $guest_kernel_fullpath
sudo cp $guest_kernel_fullpath $mntpt/guest_kernel
echo [info] copy guest rootfs: $guest_rootfs_fullpath
sudo cp $guest_rootfs_fullpath $mntpt/guest_rootfs
echo [info] copy data dir
sudo cp -r data/* $mntpt/
echo [info] sync
sync
echo [info] contents of /dev/sdb3
ls $mntpt
sleep 5
sudo umount ${sddev}3
sudo umount ${sddev}2
sudo umount ${sddev}1
sudo rmdir $mntpt
#sudo losetup -d $lodev

echo [info] finished
