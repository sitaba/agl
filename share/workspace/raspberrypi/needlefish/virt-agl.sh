#!/bin/bash 

FEATURE_NAME=$(echo $BASH_SOURCE | sed 's|^.*/||' | sed 's|\.sh||')


# https://docs.automotivelinux.org/en/needlefish/#0_Getting_Started/2_Building_AGL_Image/5_2_Raspberry_Pi_4/

AGL_TOP=/workspace/needlefish

MACHINE=virtio-aarch64
BUILD_DIR=${AGL_TOP}/build/${FEATURE_NAME}
RECIPES_DIR=${AGL_TOP}/recipes
TARGET=agl-demo-platform
NO_EXE=""


function download_agl() {
if [ ! -d "${RECIPES_DIR}" ]; then
    mkdir ${RECIPES_DIR} && pushd ${RECIPES_DIR}
    repo init -b needlefish -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
    repo sync
    popd
fi
}

function setup_site-conf() {
if [ ! -d "${AGL_TOP}/cache/downloads" ]; then
mkdir -p ${AGL_TOP}/cache/downloads
fi
if [ ! -d "${AGL_TOP}/cache/sstate-cache" ]; then
mkdir -p ${AGL_TOP}/cache/sstate-cache
fi
mkdir ${AGL_TOP}/cache/downloads
if [ ! -f "${AGL_TOP}/site.conf" ]; then
cat <<EOF> ${AGL_TOP}/site.conf
DL_DIR = "${AGL_TOP}/cache/downloads/"
SSTATE_DIR = "${AGL_TOP}/cache/sstate-cache/"
EOF
fi
}


#####################

function source_guest() {
if [ ! -d "${BUILD_DIR}" ]; then mkdir ${BUILD_DIR}; fi
source ${RECIPES_DIR}/meta-agl/scripts/aglsetup.sh -f -m ${MACHINE} -b ${BUILD_DIR} agl-demo agl-devel
}

function build_guest() {

download_agl
setup_site-conf

source_guest

ln -sf ${AGL_TOP}/site.conf conf/

if [ ! -f "conf/local.conf.org" ]; then cp conf/local.conf conf/local.conf.org; fi
cp conf/local.conf.org conf/local.conf
cat <<EOF>> conf/local.conf
EOF

if [ ! -f "conf/bblayers.org" ]; then cp conf/bblayers.conf conf/bblayers.conf.org; fi
cp conf/bblayers.conf.org conf/bblayers.conf
cat <<EOF>> conf/bblayers.conf
EOF

time bitbake ${TARGET} 2>&1 | tee bitbake_$(date +%m%d-%H%M).log

} # build_guest


while [ $# != 0 ]; do
    case $1 in
        --build-guest | -bg )
	    echo "--- Exe: build_guest"
	    exe_cmd=build_guest
	    shift
	    ;;
	--source-guest | -sg )
	    echo "--- Exe: source_guest"
	    exe_cmd=source_guest
	    shift
	    ;;
	* ) 
	    echo "Unknown option: $1"
	    NO_EXE="true"
	    shift
	    ;;
    esac
done

if [ -z "$NO_EXE" ];then
    echo =========
    eval ${exe_cmd}
fi





