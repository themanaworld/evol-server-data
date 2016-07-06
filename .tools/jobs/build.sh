#!/bin/bash

export CC=gcc-6
export LOGFILE=gcc6.log

source ./.tools/scripts/init.sh

pwd
cd ..

build_init

cd server-code
check_error $?

make_server "$1" "$2"
