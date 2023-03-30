#! /usr/bin/bash

shopt -s extglob
PS3="Type in your option number: "
DB_PATH="databases"

function validate_dbname() {

    if [[ $*  =~ ^[0-9] ]]
    then
        echo DB name must NOT start with a number
        exit 1
    fi

    if [[ $*  =~ ^_ || $* =~ _$ ]]
    then
        echo DB name must NOT start or end with underscore
        exit 1
    fi

    if [[ $* == *['!|<>{}][]"-'@#\$%^\&*()+.\`]*  ]]
    then
        echo DB name must NOT include special characters
        exit 1
    fi

    str=$*
    echo "${str// /_}" | tr 'A-Z' 'a-z'
}

function validate_db_username() {

    if [[ $*  =~ ^[0-9] ]]
    then
        echo DB username must NOT start with a number
        exit 1
    fi

    if [[ $* == *[' !|<>{}][]"-'@#\$%^\&*()+.\`]*  ]]
    then
        echo DB username must NOT include spaces or special characters
        exit 1
    fi

    echo $*
}

# Start Database Functions
function create_db() {

    if [ -d "$DB_PATH/$1" ]
    then
        echo "$1 database already exists"
        exit 1
    fi

    db_password=`echo $3 | sha1sum | cut -d ' ' -f 1`
    mkdir "$DB_PATH/$1"
    echo "$2:$db_password" > "$DB_PATH/$1/auth"
    echo $1 database was created successfully
}
# End Database Functions 


select item in "Create Database" "List Databases" "Connect To Database" "Drop Database"
do
    case $REPLY in
    1) 
        read -p "Type in the DB name: " db_name
        read -p "Type in the DB admin username: " db_username
        echo "Type in the DB admin password:"
        read -s db_password

        db_name=`validate_dbname $db_name`
        db_username=`validate_db_username $db_username`
        
        create_db $db_name $db_username $db_password
    break
    ;;
    2) echo 2
    break
    ;;
    3) echo 3
    break
    ;;
    4) echo 4
    break
    ;;
    *) echo "something else"
    break
    ;;
    esac
done
