#!/bin/bash

source ./util.sh
DB=$1

read -p "Enter your table name: " table_name
error=`validate_name $table_name`

if [ $? -eq 1 ]
then
    # Returns Error
    echo -e "\n${RED}>>>${YELLOW}Table name $error${RED}<<<${NC}\n"
    exit
fi

while [ true ]
do
    select choice in select-all-table select-spacific-columns select-spacific-row back
    do
        case $choice in 
            select-all-table)
                cat $DB/$table_name
                echo -e "\n"
                break
            ;;
            select-spacific-columns)
                read -p "Enter the index of columns you need to select seperated by comma (,): " colms
                printf -v joined '%s,' "${arr[@]}"
                elements="${joined%,}"
                cat $DB/$table_name | cut -d: -f$colms
                echo -e "\n"
                break
            ;;
            select-spacific-row)
                read -p "Enter your prinmary key to the row you need to select: " key
                if ! grep -q ^$key "$DB/$table_name" 
                    then
                        echo -e "\n${RED}This primary key is not exist${NC}\n"
                    else
                        awk -F: -v key=$key -v z=$z '{if ($1==key) {print $0}}' $DB/$table_name
                fi
            ;;
            back)
                exit
            ;;
        esac
    done
done
