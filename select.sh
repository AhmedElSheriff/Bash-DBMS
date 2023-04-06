#!/bin/bash

source ./util.sh
path=.

while [ true ]
do
    select choice in select-all-table select-spacific-columns select-spacific-row exit
    do
        case $choice in 
            select-all-table)
                read -p "Enter your table name: " table_name
                cat $path/$table_name
                echo -e "\n"
                break
            ;;
            select-spacific-columns)
                read -p "Enter the table name you need to select from: " table_name
                read -p "Enter the index of columns you need to select seperated by comma (,): " colms
                printf -v joined '%s,' "${arr[@]}"
                elements="${joined%,}"
                cat $path/$table_name | cut -d: -f$colms
                echo -e "\n"
                break
            ;;
            select-spacific-row)
                read -p "Enter the table name you need to select from: " table_name
                read -p "Enter your prinmary key to the row you need to select: " key
                if ! grep -q ^$key "$path/$table_name" 
                    then
                        echo -e "\n${RED}This primary key is not exist${NC}\n"
                    else
                        awk -F: -v key=$key -v z=$z '{if ($1==key) {print $0}}' $path/$table_name
                fi
            ;;
            exit)
                exit
            ;;
        esac
    done
done
