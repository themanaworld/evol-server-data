#!/bin/bash

source ./.tools/scripts/init.sh

cd ../server-data

export host=$1
cd sql-files

export CMD="mysql --force -u root -proot --host=${host}"
check_error $?
echo $CMD <./initremote.sql
$CMD <./initremote.sql
check_error $?

export CMD="mysql -u evol -pevol --host=${host} evol"
echo Creating tables...
echo $CMD <main.sql
$CMD <main.sql
check_error $?
echo $CMD <logs.sql
$CMD <logs.sql
check_error $?
