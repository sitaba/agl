#!/bin/bash


IMG_NAME=kz/build_env_for_agl
CMD=/bin/bash
USER_SETTING="-u $(id -u $USER):$(id -g $USER) -v $(pwd)/share/docker-home:/home/${USER}"
VISUAL_SETTING="-e DISPLAY=unix${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix"
XAUTHORITY="-v $HOME/.Xauthority:$HOME/.Xauthority"


while [ "$#" -ne 0 ]; do
    case $1 in
	-p | --privileged)
	    echo "--- Enable: privileged"
	    PRIVILEGED="--privileged"
	    shift
	    ;;
	-r | --root)
	    echo "--- Enable: root"
	    USER_SETTING=""
	    XAUTHORITY="-v $HOME/.Xauthority:/root/.Xauthority"
	    shift
	    ;;
	-c=* | --command=*)
	    if [ "${1:1:1}" == "c" ]; then CMD=${1:3}; else CMD=${1:10}; fi
	    echo "--- Cmd set: ${CMD}"
	    shift
	    ;;
	*)
	    echo "--- Unknown Option: $1"
	    exit
	    ;;
    esac
done

xhost +local:
echo "=== Execute Command ==="
echo docker run --rm -it \
	-v /etc/group:/etc/group:ro \
	-v /etc/passwd:/etc/passwd:ro \
	-v $(pwd)/share/workspace/raspberrypi:/workspace \
	${PRIVILEGED} \
	${USER_SETTING} \
        ${VISUAL_SETTING} \
	${XAUTHORITY} \
	${IMG_NAME} \
	${CMD}
echo "======================="
docker run --rm -it \
	-v /etc/group:/etc/group:ro \
	-v /etc/passwd:/etc/passwd:ro \
	-v $(pwd)/share/workspace/raspberrypi:/workspace \
	${PRIVILEGED} \
	${USER_SETTING} \
        ${VISUAL_SETTING} \
	${XAUTHORITY} \
	${IMG_NAME} \
	${CMD}
xhost -local:
