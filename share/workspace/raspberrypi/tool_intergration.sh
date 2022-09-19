#!/bin/bash -eu

if [ $# -ne 2 ]; then
    echo "Need two arguments: 1:host script, 2:guest build dir"
    exit
fi

host_script=$1
host_base_name=$(echo $host_script | sed 's|^.*/||' | sed 's|\.sh$||')
host_dir=$(readlink -e build/${host_base_name})
guest_kernel_fullpath=$(readlink -e $2/tmp/deploy/images/*/Image)
guest_rootfs_fname=$(ls $2/tmp/deploy/images/*/ | grep -v sha256sum | grep .ext4 | tail -n 1)
guest_rootfs_fullpath=$(readlink -e $2/tmp/deploy/images/*/${guest_rootfs_fname})

echo [info] HOST script name: $host_script
if [ ! -f "$host_script" ]; then echo "No such file: $host_script"; exit; fi
echo [info] HOST dir: $host_dir
if [ ! -d "$host_dir" ]; then echo "No such directory: $host_dir"; exit; fi
echo [info] GUEST kernel path: $guest_kernel_fullpath
if [ ! -f "$guest_kernel_fullpath" ]; then echo "No such file: $guest_kernel_fullpath"; exit; fi
echo [info] GUEST rootfs path: $guest_rootfs_fullpath
if [ ! -f "$guest_rootfs_fullpath" ]; then echo "No such file: $guest_rootfs_fullpath"; exit; fi


echo [info] source host env
set +eu
source ./$host_script --source-host
set -eu
host_rootfs_dir=$(readlink -e ${host_dir}/tmp/work/${MACHINE}*/${TARGET}/*/rootfs/)
echo [info] HOST rootfs dir path: $host_rootfs_dir
if [ ! -d "$host_rootfs_dir" ]; then echo "No such file: $host_rootfs_dir"; exit; fi

echo [info] copy guest files to host rootfs
echo [cmd] cp $guest_kernel_fullpath $host_rootfs_dir/guest_kernel
cp $guest_kernel_fullpath $host_rootfs_dir/guest_kernel
echo [cmd] cp $guest_rootfs_fullpath $host_rootfs_dir/guest_rootfs
cp $guest_rootfs_fullpath $host_rootfs_dir/guest_rootfs
echo [cmd] sync
sync
echo [cmd] ls $host_rootfs_dir
ls $host_rootfs_dir
sleep 5

echo [info] intergration to one host rootfs
echo [cmd] bitbake ${TARGET} -c image_wic -f
bitbake ${TARGET} -c image_wic -f 2>&1 | tee bitbake_image-wic_$(date +%m%d-%H%M).log
echo [cmd] sync
sync
echo [cmd] ls $host_rootfs_dir
ls $host_rootfs_dir
sleep 5
echo [cmd] bitbake ${TARGET} -c image_complete
bitbake ${TARGET} -c image_complete 2>&1 | tee bitbake_image-complete_$(date +%m%d-%H%M).log
echo [cmd] ls $host_rootfs_dir
ls $host_rootfs_dir

echo [info] finished
