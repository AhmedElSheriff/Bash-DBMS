#! /usr/bin/bash

source ./util.sh

DB=$1

read -p "Enter your table name: " table_name

if [[ ! -f "$DB/$table_name" ]]
then
    echo -e "\n${YELLOW}Table does NOT exist${NC}\n"
    exit
fi

primary_key=`tail -n 1 $DB/.$table_name`
cols=`head -n 1 $DB/.$table_name`
cols_formatted=(${cols//:/ })

while [ true ]
do
    echo -e "\nEnter the value of ${YELLOW}the primary key (${cols_formatted[$((primary_key-1))]}) ${NC}"

    read key

    result=`awk -F: -v key=$key -v primary_key=$primary_key '{ if($primary_key == key){print NR;exit}}' $DB/$table_name`

    if [[ ! $result ]]
    then
        #Key does not exist
        echo -e "\n${RED}>>>${YELLOW}Key does NOT exist in the database${RED}<<<${NC}\n"
        continue
    fi

    sed -i "${result}d" $DB/$table_name

    echo -e "\n${GREEN}Row deleted successfuly!${NC}\n"

    break
    # awk -F: -v primary_key=$primary_key -v key=$key '{if($primary_key != key){print $0}}' $DB/$table_name > tmp && mv tmp $DB/$table_name
done