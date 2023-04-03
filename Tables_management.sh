#!/bin/bash

source ./util.sh

DB=databases/$db_name

function Create_table() {
    
    echo " \"Spaces should be avoided and replace with _\" "
    read -p "Enter your table name: " table_name

    # while [[ true ]]
    # do

    result=`validate_dbname $table_name`

    if [ $? -eq 1 ]
    then
        # Returns Error
        echo -e "\n${RED}>>>${YELLOW}Table name $result${RED}<<<${NC}\n"
        break
    fi

    # if [[ ! $table_name ]]
    # then
    #     echo "Table name can not be NULL"
    #     read -p "Enter your table name: " table_name
    #     continue
    # fi

    # if [[ ${table_name:0:1} == [0-9] ]]
    # then
    #     echo "Table name should not start with number"
    #     read -p "Enter your table name: " table_name
    #     continue
    # fi

    # if [[ $table_name == *[" "'!'\/@#\$%^\&*()+]* ]]
    # then
    #         echo "Table name should not contain spicial character"
    #         read -p "Enter your table name: " table_name
    #     continue
    # fi
    # break
    # done

    # cd $DB
    # if [[ -f $table_name ]]
    # then
    #     echo "file is already exist"
	# 	exit
    # else
    #     touch $table_name
    # fi


    # i=0
    # j=0
    # while [ true ]
    # do
    # read -p "Enter your columns names and its type each sperated by enter and press ctrl+d to end. " Input
    # #When ^D is used, read ends up with the exit code "1"

    # if [[ $? == 1 ]]

    # then
    #     echo "[Ctrl+D] is captured"
    #     break
    # fi

    # cols[i]=$Input
    # i=$((i+1))

    # select choice in int float string
    #     do
    #     case $choice in
    #     int)
    #     types[j]=int
    #     j=$((j+1))
    #     break
    #     ;;
    #     float)
    #     types[j]=float
    #     j=$((j+1))
    #     break
    #     ;;
    #     string)
    #     types[j]=string
    #     j=$((j+1))
    #     break
    #     ;;
    #     esac
    # done

    # done

    # printf -v joined '%s:' "${cols[@]}"
    # echo "${joined%:}" >> .$table_name

    # printf -v joined '%s:' "${types[@]}"
    # echo "${joined%:}" >> .$table_name
}

function List_tables (){
	cd $DB

	select choice in "List all tables" "Show content of spacific table" exit
	do
	case $choice in

	"List all tables") ls -1;;

	"Show content of spacific table")
	read -p "Enter your table name: " table_name
	if [[ -f $table_name ]]
	then
	cat $table_name
	else
	echo Table is not exist
	fi
	;;

	exit) break
	esac
	done
}

function Drop_table (){
	cd $DB

	read -p "Enter your table name: " table_name

	if [[ -f $table_name ]]
	then
			rm -i $table_name
	else
			echo Table is not exist
	fi
}

while [ true ]
do
    select choice in "Create table" "List tables" "Drop table" exit
    do
        case $choice in
            "Create table")

                echo " \"Spaces should be avoided and replace with _\" "
                read -p "Enter your table name: " table_name

                result=`validate_dbname $table_name`

                if [ $? -eq 1 ]
                then
                    # Returns Error
                    echo -e "\n${RED}>>>${YELLOW}Table name $result${RED}<<<${NC}\n"
                    break
                fi
            ;;

            "List tables")
                List_tables	
            ;;
            "Drop table")
                Drop_table	
            ;;
            exit)
                exit
            ;;
        esac
    done
done