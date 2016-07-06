#!/bin/bash

source ./.tools/scripts/init.sh

update_repos
aptget_update

aptget_install $*

do_init_data
