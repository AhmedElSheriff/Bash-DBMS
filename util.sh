#! /usr/bin/bash

PS3="Type in your option number: "
DB_PATH="databases"
YELLOW='\033[1;33m'   
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'

function validate_name() {

    if [[ ! $* ]]
    then
        echo must NOT be null
        return 1
    fi

    if [[ $*  =~ ^[0-9] ]]
    then
        echo must NOT start with a number
        return 1
    fi

    if [[ $*  =~ ^_ || $* =~ _$ ]]
    then
        echo must NOT start or end with underscore
        return 1
    fi

    if [[ $* == *['!|<>{}][]"-'@#\$%^\&*()+.\`]*  ]]
    then
        echo must NOT include special characters
        return 1
    fi
}

function validate_db_username() {

    if [[ ! $* ]]
    then
        echo DB name must NOT be null
        return 1
    fi

    if [[ $*  =~ ^[0-9] ]]
    then
        echo DB username must NOT start with a number
        return 1
    fi

    if [[ $* == *[' !|<>{}][]"-'@#\$%^\&*()+.\`]*  ]]
    then
        echo DB username must NOT include spaces or special characters
        return 1
    fi
}