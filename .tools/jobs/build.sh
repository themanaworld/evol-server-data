#!/bin/bash

export LOGFILE=gcc6.log

source ./.tools/scripts/init.sh

pwd
cd ..

build_init

cd server-code
check_error $?

make_server "$1" "$2"
