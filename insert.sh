#! /usr/bin/bash

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

if [[ ! -f "$DB/$table_name" ]]
then
    echo -e "\n${YELLOW}Table does NOT exist${NC}\n"
    exit
fi


cols=`head -n 1 $DB/.$table_name`
cols_formatted=${cols//:/ }

types=`head -n 2 $DB/.$table_name | tail -n 1`
types_formatted=(${types//:/ })

primary_key=`head -n 3 $DB/.$table_name | tail -n 1`

index=0

for col in $cols_formatted
do
    while [ true ]
    do
        data_type=${types_formatted[$index]}
        
        read -p "Enter value of $col($data_type): " input
        
        if [[ $primary_key == $((index+1)) && `awk -F: -v input="$input" -v primary_key=$primary_key '{ if($primary_key == input){print NR}}' $DB/$table_name` ]]
        then
            # Primary Key Match
            echo -e "\n${RED}>>>${YELLOW}$input already EXISTS in the table${RED}<<<${NC}\n"
            continue
        fi
        
        error=`validate_table_data $data_type $input`
        if [ $? -eq 1 ]
        then
            # Returns Error
            echo -e "\n${RED}>>>${YELLOW}$error${RED}<<<${NC}\n"
            continue
        fi
        
        data[$index]="$input"
        let index++
        
        break
    done
done

printf -v joined '%s:' "${data[@]}"
echo "${joined%:}" >> $DB/$table_name

echo -e "\n${GREEN}Data inserted successfuly!${NC}\n"
