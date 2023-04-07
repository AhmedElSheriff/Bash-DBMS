#!/bin/bash

source ./util.sh

if [[ !$1 ]]
then
    echo -e "\n${YELLOW}Please run the program from ${RED}dbms.sh ${YELLOW}file\n${NC}"
    exit
fi

DB=databases/$1/

while [ true ]
do
    select choice in "Create table" "List tables" "Drop table" "Insert Into Table" "Select From Table" "Update Table" "Delete From Table" "Back"
    do
        case $choice in
            "Create table")

                echo "\"Spaces should be avoided and replace with _\" "
                read -p "Enter your table name: " table_name

                error=`validate_name $table_name`

                if [ $? -eq 1 ]
                then
                    # Returns Error
                    echo -e "\n${RED}>>>${YELLOW}Table name $error${RED}<<<${NC}\n"
                    break
                fi

                if [[ -f "databases/$1/$table_name" ]]
                then
                    echo -e "\n${YELLOW}file is already exist${NC}\n"
                	exit
                #else
                    #touch $table_name
                fi


                index=0

                while [ true ]
                do
                    read -p "Enter your columns names and its type each sperated by enter and press ctrl+d to end: " Input

                    #When ^D is used, read ends up with the exit code "1"
                    if [[ $? == 1 ]]

                    then
                        echo -e "\n${GREEN}[Ctrl+D] is captured${NC}\n"
                        break
                    fi
                    
                    error=`validate_name $Input`

                    if [ $? -eq 1 ]
                    then
                        # Returns Error
                        echo -e "\n${RED}>>>${YELLOW}Column name $error${RED}<<<${NC}\n"
                        continue
                    fi

                    #array of inputs
                    cols[index]=$Input
                    #index=$((index+1))

                    #enter columns types
                    select choice in int float string
                        do
                        case $choice in
                            int)
                                types[index]=int
                                index=$((index+1))
                                break
                            ;;
                            float)
                                types[index]=float
                                index=$((index+1))
                                break
                            ;;
                            string)
                                types[index]=string
                                index=$((index+1))
                                break
                            ;;

                            *)
                                echo -e "\n${YELLOW}Choose between [1-3]${NC}\n"
                            ;;
                        esac
                    done

                    if [[ ! $primary_key ]]
                    then
                        read -p "Do you want this coulmn to be the primary key? (y/n) " primary_key

                        if [[ `tr ['A-Z'] ['a-z'] <<< $primary_key` == "y" ]]
                        then
                            primary_key=$index
                        fi
                    fi

                done

                printf -v joined '%s:' "${cols[@]}"
                echo "${joined%:}" >> databases/$1/.$table_name

                printf -v joined '%s:' "${types[@]}"
                echo "${joined%:}" >> databases/$1/.$table_name
                
                echo ${primary_key} >> databases/$1/.$table_name

                touch databases/$1/$table_name
                break
            ;;

            "List tables")
                while [ true ]
                do
                    select choice in "List all tables" "Show content of spacific table" "Back"
                    do
                        case $choice in

                            "List all tables") 
                                ls -1 databases/$1/
                                break
                            ;;
                            "Show content of spacific table")
                                read -p "Enter your table name: " table_name
                                if [[ -f "databases/$1/$table_name" ]]
                                then
                                    cat databases/$1/$table_name
                                else
                                    echo -e "\n${YELLOW}Table is not exist${NC}\n"
                                fi
                            break
                            ;;
                            "Back") 
                                break 3
                            ;;
                        esac
                    done
                done
            ;;
            "Drop table")
                read -p "Enter your table name: " table_name

                if [[ ${table_name:0:1} == . ]]
                    then
                        echo -e "\n${RED}you don't have permission to delete this type of files${NC}\n"
                
                elif [[ -f "databases/$1/$table_name" ]]
                    then
                        rm -i databases/$1/$table_name
                else
                        echo -e "\n${YELLOW}Table does NOT exist${NC}\n"
                fi	
                break 
            ;;
            "Insert Into Table")

                ./insert.sh $DB

                break
            ;;
            "Delete From Table")

                ./delete.sh $DB

                break
            ;;
            "Select From Table")
                ./select.sh $DB
                break
            ;;
            "Update Table")
                ./update.sh $DB
                break
            ;;
            "Back")
                exit
            ;;
        esac
    done
done