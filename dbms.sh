#! /usr/bin/bash

shopt -s extglob
PS3="Type in your option number: "
DB_PATH="databases"
YELLOW='\033[1;33m'   
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'

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
}

function authorize() {
    if [ ! -d "$DB_PATH/$1" ]
    then
        echo "$1 database does NOT exist"
        exit 1
    fi

    if [[ $2 != `cut -d : "$DB_PATH/$1/auth" -f 1` ]]
    then
        echo "The username you have entered is NOT correct"
        exit 1
    fi

    if [[ `sha1sum <<< $3 | cut -d ' ' -f 1` != `cut -d : "$DB_PATH/$1/auth" -f 2` ]]
    then
        echo "The password you have entered is NOT correct"
        exit 1
    fi
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
}


# End Database Functions 

while [ true ]
do
    select item in "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit"
    do
        case $REPLY in
        1) 
            #Create Database
            read -p "Type in the DB name: " db_name
            read -p "Type in the DB admin username: " db_username
            echo "Type in the DB admin password:"
            read -s db_password

            result=`validate_dbname $db_name`
            if [ $? -eq 1 ]
            then
                # Returns Error
                echo -e "\n${RED}>>>${YELLOW}$result${RED}<<<${NC}\n"
                break
            fi

            db_name=`echo "${db_name// /_}" | tr 'A-Z' 'a-z'`

            result=`validate_db_username $db_username`
            if [ $? -eq 1 ]
            then
                # Returns Error
                echo -e "\n${RED}>>>${YELLOW}$result${RED}<<<${NC}\n"
                break
            fi

            result=`create_db $db_name $db_username $db_password`
            if [ $? -eq 1 ]
            then
                # Returns Error
                echo -e "\n${RED}>>>${YELLOW}$result${RED}<<<${NC}\n"
                break
            fi

            echo -e "\n${GREEN}$db_name database was created successfully${NC}\n"
        break
        ;;
        2) 
            # List Database
            echo -e "\n"
            databases=`ls $DB_PATH`
            if [[ $databases > 1 ]]
            then
                printf "%10s %s\n" "DB Name" "| Tables Count" "---------------------------"
            else
                echo -e "\n${RED}>>>${YELLOW}You currently don NOT have any databases available${RED}<<<${NC}\n"
            fi
            
            for database in $databases
            do
                count=`find $DB_PATH/$database -type f ! -name auth | wc -l`
                printf "%10s %s\n" $database "| $count"
            done
            echo -e "\n"
        break
        ;;
        3) 
            # Connect To Database
            read -p "Type in the DB name: " db_name
            read -p "Type in the DB admin username: " db_username
            echo "Type in the DB admin password:"
            read -s db_password

            result=`authorize $db_name $db_username $db_password`
            
            if [ $? -eq 1 ]
            then
                # Returns Error
                echo -e "\n${RED}>>>${YELLOW}$result${RED}<<<${NC}\n"
                break
            fi
            
            echo -e "\n${GREEN}Connected Successfully${NC}\n"

            ./Tables_management.sh
        break
        ;;
        4) 
            # Drop Database
            read -p "Type in the DB name: " db_name
            read -p "Type in the DB admin username: " db_username
            echo "Type in the DB admin password:"
            read -s db_password

            result=`authorize $db_name $db_username $db_password`

            if [ $? -eq 1 ]
            then
                # Returns Error
                echo -e "\n${RED}>>>${YELLOW}$result${RED}<<<${NC}\n"
                break
            fi

            rm -r "$DB_PATH/$db_name"

            if [ $? -eq 0 ]
            then
                echo -e "\n${GREEN}The database has been deleted Successfuly${NC}\n"
            else
                echo -e "\n${RED}Failed to delete database${NC}\n"
            fi
        break
        ;;
        5)
            exit 1
        ;;
        *) 
            echo -e "\n"
            echo Invalid Choice
            echo -e "\n"
        break
        ;;
        esac
    done
done