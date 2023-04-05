#!/bin/bash

source ./util.sh

DB=databases/$1/

while [ true ]
do
    select choice in "Create table" "List tables" "Drop table" exit
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
                    read -p "Enter your columns names and its type each sperated by enter and press ctrl+d to end. " Input

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

                done

                printf -v joined '%s:' "${cols[@]}"
                echo "${joined%:}" >> databases/$1/.$table_name

                printf -v joined '%s:' "${types[@]}"
                echo "${joined%:}" >> databases/$1/.$table_name
                
                touch databases/$1/$table_name
                break
            ;;

            "List tables")
                select choice in "List all tables" "Show content of spacific table" exit
                do
                    case $choice in

                        "List all tables") 
                        ls -1 databases/$1/
                        continue
                        ;;
                        "Show content of spacific table")
                        read -p "Enter your table name: " table_name
                        if [[ -f "databases/$1/$table_name" ]]
                        then
                        cat databases/$1/$table_name
                        else
                        echo -e "\n${YELLOW}Table is not exist${NC}\n"
                        fi
                        ;;
                        exit) break 2
                        ;;
                    esac
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
                        echo -e "\n${YELLOW}Table is not exist${NC}\n"
                fi	
                break 
            ;;
            exit)
                exit
            ;;
        esac
    done
done