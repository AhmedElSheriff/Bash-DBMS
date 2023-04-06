#!/bin/bash

source ./util.sh

DB=./databases/DD
SCHEMA=./databases/EE
primary_key_column=`tail -n 1 $SCHEMA`
#echo $primary_key_column

while [ true ]
do
    select choice in update_column exit
    do
        case $choice in 
            update_column)
                column_name=`awk -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } NR==1 { print $primary_key_column;exit}' $SCHEMA`
                type=`awk -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } NR==2 { print $primary_key_column;exit}' $SCHEMA`                        
                echo -e "\nEnter the value of ${YELLOW}the primary key ($column_name)${NC} that its type is ${YELLOW}($type)${NC}"
                read primary_key
                #read -p "Enter the primary key of row you need to update: " primary_key
                #row=0
                row=`awk -v primary_key=$primary_key -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } \
                $primary_key_column == primary_key { print NR ;exit} ' $DB`
                #echo $row
                if [[ ! $row ]]
                then
                    echo -e "\n${RED}This primary key is not exist${NC}\n"
                    exit
                fi


                while [ true ]
                do
                    read -p "Enter number of columns you need to update: " columns
                    num_of_columns=`head -n 2 $SCHEMA | tail -n 1 | tr ":" " " | wc -w`
                    if (($columns > $num_of_columns || $columns < 0))
                    then
                        echo -e "\n${RED}Number of columns must be between 1 and $num_of_columns${NC}\n"
                        continue
                    else
                        break
                    fi
                done


                for ((i=0;i<$columns;i++))
                do  
                    while [ true ]
                    do
                        read -p "Enter the spacific number of column you need to update: " column_num
                        num_of_columns=`head -n 2 $SCHEMA | tail -n 1 | tr ":" " " | wc -w`
                        if (($column_num > $num_of_columns || $column_num < 0))
                        then
                            echo -e "\n${RED}column's number must be between 1 and $num_of_columns${NC}\n"
                            continue
                        else
                            break
                        fi
                    done
                    
                    while [ true ]
                    do

                        
                        column_name=`awk -v column_num=$column_num 'BEGIN { FS=":" } NR==1 { print $column_num}' $SCHEMA`
                        type=`awk -v column_num=$column_num 'BEGIN { FS=":" } NR==2 { print $column_num}' $SCHEMA`                        
                        echo -e "\nEnter the value of column ${YELLOW}$column_name${NC} that its type is ${YELLOW}($type)${NC}"
                        read column_value
                        case $type in
                            int)
                                if [[ ! $column_value =~ ^[+-]?[0-9]+$ ]]; then
                                    echo -e "\n${RED}Value must be integer.${NC}\n"
                                    continue
                                else
                                    break
                                fi
                            ;;
                            float)
                                if [[ ! $column_value =~ ^[+-]?[0-9]+[.][0-9]*$ ]]; then
                                    echo -e "\n${RED}Value must be float.${NC}\n"
                                    continue
                                else
                                    break
                                fi
                            ;;
                            string)
                                echo -e "\n${GREEN}Your value added as a string${NC}\n"
                                break
                            ;;
                        esac
                    done
                    
                    awk -v row=$row -v i=$column_num -v v=$column_value 'BEGIN { FS=OFS=":" } NR==row { $i = v } 1' \
                    $DB > ./databases/tmp && rm $DB && mv ./databases/tmp $DB
                done
            ;;
            exit)
                exit
            ;;
        esac
    done
done