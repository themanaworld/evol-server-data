#!/bin/sh

gprof --inline-file-names ./${1} >gprof_${1}.txt
