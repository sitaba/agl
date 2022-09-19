#!/bin/bash

IMG_NAME=kz/build_env_for_agl


while [ "$#" != 0 ]; do
    case $1 in
        -f | --full-build )
	    echo "enable: --no-cahche=true"
	    OPTION=" --no-cache=true"
	    shift
	    ;;
        *)
	    echo "Unknow: $1"
	    shift
	    ;;
    esac
done

echo "========================"

pushd workspace
docker image build -t ${IMG_NAME} ${OPTION} .
popd
