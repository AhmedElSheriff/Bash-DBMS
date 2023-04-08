#!/bin/bash

source ./util.sh

if [[ ! $1 ]]
then
    echo -e "\n${YELLOW}Please run the program from ${RED}dbms.sh ${YELLOW}file\n${NC}"
    exit
fi

DB=$1

read -p "Enter your table name: " table_name
error=`validate_name $table_name`

if [ $? -eq 1 ]
then
    # Returns Error
    echo -e "\n${RED}>>>${YELLOW}Table name $error${RED}<<<${NC}\n"
    exit
fi

if [ ! -f $DB/$table_name ]
then
    # Returns Error
    echo -e "\n${RED}Table does NOT exist${NC}\n"
    exit
fi

SCHEMA=$DB/.$table_name
primary_key_column=`head -n 3 $SCHEMA | tail -n 1`

echo $primary_key_column

while [ true ]
do
    select choice in "Select all table rows" "Select specific columns" "Select specific row" "Back"
    do
        case $choice in 
            "Select all table rows")
                echo -e "\n"
                cat $DB/$table_name
                echo -e "\n"
                break
            ;;
            "Select specific columns")
                read -p "Enter the index of columns you need to select seperated by comma (,): " colms

                num_of_columns=`head -n 2 $SCHEMA | tail -n 1 | tr ":" " " | wc -w`
                cols_formatted=${colms//,/ }
                for val in $cols_formatted
                do
                    if [[ $val > $num_of_columns || $val < 0 ]]
                    then
                        echo -e "\n${RED}your columns values should be between 0 and $num_of_columns${NC}\n"
                        break 2
                    fi
                done

                if [[ ! $colms =~ ^[0-9]+[,0-9]*$ ]]
                then
                    echo -e "\n${RED}The value must be column numbers seperated by comma${NC}\n"
                    break
                else
                    echo -e "\n"
                    cat $DB/$table_name | cut -d: -f$colms
                    echo -e "\n"
                    break
                fi
                
            ;;
            "Select specific row")
                read -p "Enter your primary key to the row you need to select: " key

                exist=`awk -v key=$key -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } \
                $primary_key_column == key { print 1 ;exit} ' $DB/$table_name`
                
                if [[ $exist != 1 ]] 
                    then
                        echo -e "\n${RED}This primary key is not exist${NC}\n"
                    else
                        echo -e "\n"
                        awk -F: -v key=$key '{if (($1==key)) {print $0}}' $DB/$table_name
                        echo -e "\n"
                fi
            ;;
            "Back")
                exit
            ;;
        esac
    done
done
