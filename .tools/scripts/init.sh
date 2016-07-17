#!/bin/bash

mkdir logs

export dir=$(pwd)
export ERRFILE=${dir}/logs/${LOGFILE}

cat /etc/os-release

rm ${ERRFILE}

function check_error {
    if [ "$1" != 0 ]; then
        echo "Error $1"
        exit $1
    fi
}

function update_repos {
    if [ "$CI_SERVER" == "" ];
    then
        return
    fi

    export DATA=$(cat /etc/resolv.conf|grep "nameserver 1.10.100.101")
    if [ "$DATA" != "" ];
    then
        echo "Detected local runner"
        sed -i 's!http://httpredir.debian.org/debian!http://1.10.100.103/debian!' /etc/apt/sources.list
    else
        echo "Detected non local runner"
    fi
}

function gitclone1 {
    echo git clone $2 $3
    git clone $2 $3
    if [ "$?" != 0 ]; then
        echo git clone $1 $3
        git clone $1 $3
        return $?
    fi
    return $?
}

function gitclone {
    export name1=$1/$2
    export name2=${CI_BUILD_REPO##*@}
    export name2=https://${name2%/*}/$2

    gitclone1 "$name1" "$name2" $3
    if [ "$?" != 0 ]; then
        sleep 1s
        gitclone1 "$name1" "$name2" $3
        if [ "$?" != 0 ]; then
            sleep 3s
            gitclone1 "$name1" "$name2" $3
            if [ "$?" != 0 ]; then
                sleep 5s
                gitclone1 "$name1" "$name2" $3
            fi
        fi
    fi
    check_error $?
}

function update_repos {
    if [ "$CI_SERVER" == "" ];
    then
        return
    fi

    export DATA=$(cat /etc/resolv.conf|grep "nameserver 1.10.100.101")
    if [ "$DATA" != "" ];
    then
        echo "Detected local runner"
        sed -i 's!http://httpredir.debian.org/debian!http://1.10.100.103/debian!' /etc/apt/sources.list
    else
        echo "Detected non local runner"
    fi
}

function aptget_update {
    update_repos
    apt-get update
    if [ "$?" != 0 ]; then
        sleep 1s
        apt-get update
        if [ "$?" != 0 ]; then
            sleep 1s
            apt-get update
        fi
    fi
    check_error $?
}

function aptget_install {
    apt-get -y -qq install $*
    if [ "$?" != 0 ]; then
        sleep 1s
        apt-get -y -qq install $*
        if [ "$?" != 0 ]; then
            sleep 2s
            apt-get -y -qq install $*
        fi
    fi
    check_error $?
}

function make_server {
    ls -la ../server-data
    ls -la ../server-data/plugins
    export CPPFLAGS="$CPPFLAGS -DI_AM_AWARE_OF_THE_RISK_AND_STILL_WANT_TO_RUN_HERCULES_AS_ROOT"
    echo "autoreconf -i"
    autoreconf -i
    check_error $?
    echo "./configure $1"
    ./configure $1
    export err="$?"
    if [ "$err" != 0 ]; then
        echo "Error $err"
        echo cat config.log
        cat config.log
        exit $err
    fi
    echo "make -j2"
    make -j2
    check_error $?
    echo "make -j2 plugin.script_mapquit"
    make -j2 plugin.script_mapquit
    check_error $?
    make install
    check_error $?

    cd src/evol
    echo "autoreconf -i"
    mkdir m4
    autoreconf -i
    check_error $?
    mkdir build
    cd build
    echo "../configure $2"
    ../configure $2
    check_error $?
    echo "make -j2 V=0"
    make -j2 V=0
    check_error $?
    cd ../../../..
    ls -la server-data/plugins
}

function do_init_data {
    mkdir shared
    cd ..
    rm -rf server-data
    cp -r serverdata server-data
    ls -la server-data
    check_error $?
}

function do_init_tools {
    cd ..
    rm -rf tools
    gitclone https://gitlab.com/evol evol-tools.git tools
}

function do_init {
    do_init_data
    rm -rf server-code
    gitclone https://gitlab.com/evol hercules.git server-code
    check_error $?
    cd server-code/src
    check_error $?
    gitclone https://gitlab.com/evol evol-hercules.git evol
    check_error $?
    cd ../..
    check_error $?
    mkdir -p server-data/plugins
}

function build_init {
    if [ "$CI_SERVER" == "" ];
    then
        return
    fi
    mkdir -p /local/bin
    echo "#!/bin/bash" > /local/bin/id
    echo "echo 1000" >> /local/bin/id
    export PATH="/local/bin:$PATH"
    chmod +x /local/bin/id
    echo "fake id check"
    id

    cd server-code/src/evol
    source tools/vars.sh
    check_error $?
    cd ../../..
    check_error $?
    echo $CC --version
    $CC --version
    check_error $?
}

function init_configs {
    cd tools/localserver
    ./installconfigs.sh
    cd ../..
    cp server-data/.tools/conf/$1/* server-data/conf/import/
    ls -la server-data/conf/import
    cat server-data/conf/import/inter_conf.txt
}
