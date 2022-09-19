#!/bin/bash

FEATURE_NAME=$(echo $BASH_SOURCE | sed 's|^.*/||' | sed 's|\.sh||')
NO_EXE=""


AGL_TOP=/workspace/lamprey

MACHINE=raspberrypi4
BUILD_DIR=${AGL_TOP}/build/${FEATURE_NAME}
RECIPES_DIR=${AGL_TOP}/recipes
TARGET=agl-image-weston


function download_agl() {
if [ ! -d "${RECIPES_DIR}" ]; then
    mkdir ${RECIPES_DIR} && pushd ${RECIPES_DIR}
    repo init -b lamprey -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
    repo sync
    popd
fi
}


function setup_site-conf() {
if [ ! -f "${AGL_TOP}/site.conf" ]; then
cat <<EOF> ${AGL_TOP}/site.conf
DL_DIR = "${AGL_TOP}/cache/downloads/"
SSTATE_DIR = "${AGL_TOP}/cache/sstate-cache/"
EOF
fi
}


###############################################

function show_target_list() {
source ${RECIPES_DIR}/meta-agl/scripts/aglsetup.sh -h
}

function source_host() {
if [ ! -d "${BUILD_DIR}" ]; then mkdir ${BUILD_DIR}; fi
source ${RECIPES_DIR}/meta-agl/scripts/aglsetup.sh -f -m ${MACHINE} -b ${BUILD_DIR} agl-demo agl-devel
}

function build_host() {

download_agl
setup_site-conf

#if [ ! -d "${BUILD_DIR}" ]; then mkdir ${BUILD_DIR}; fi
#source ${RECIPES_DIR}/meta-agl/scripts/aglsetup.sh -f -m ${MACHINE} -b ${BUILD_DIR} agl-demo agl-devel
source_host

ln -sf ${AGL_TOP}/site.conf conf/

if [ ! -f "conf/local.conf.org" ]; then cp conf/local.conf conf/local.conf.org; fi
cp conf/local.conf.org conf/local.conf
cat <<EOF>> conf/local.conf
#IMAGE_INSTALL:append = " cluster-gauges-qtcompositor"
#IMAGE_INSTALL:remove = " agl-compositor"
IMAGE_INSTALL:append = " openssh openssh-sftp-server"
IMAGE_INSTALL:append = " qemu"
#IMAGE_INSTALL:append = " virglrenderer"
#IMAGE_INSTALL:append = " libsdl2"
#PACKAGECONFIG:append:pn-libsdl2 = " wayland gles2 arm-neon"
#PACKAGECONFIG:remove:pn-libsdl2 = " x11 opengl"
#PACKAGECONFIG:append:pn-qemu = " sdl virglrenderer kvm glx"
#PACKAGECONFIG:remove:pn-libeproxy = " x11"
#PACKAGECONFIG:remove:pn-gtk+3 = " x11"
EOF

if [ ! -f "conf/bblayers.org" ]; then cp conf/bblayers.conf conf/bblayers.conf.org; fi
cp conf/bblayers.conf.org conf/bblayers.conf
cat <<EOF>> conf/bblayers.conf
EOF

time bitbake ${TARGET} 2>&1 | tee bitbake_$(date +%m%d-%H%M).log

} # build_host


while [ $# != 0 ]; do
    case $1 in
        --build-host | -bh )
	    echo "--- Exe: build_host"
	    exe_cmd=build_host
	    shift
	    ;;
	--source-host | -sh )
	    echo "--- Exe: source_host"
	    exe_cmd=source_host
	    shift
	    ;;
        --show-target-list | -stl )
	    echo "--- Exe: show_target_list"
	    exe_cmd=show_target_list
	    shift
	    ;;
	* )
	    echo "Unknown option: $1"
	    NO_EXE="true"
	    shift
	    ;;
    esac
done

if [ -z "$NO_EXE" ]; then
    echo ==========
    eval ${exe_cmd}
fi

