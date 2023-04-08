#!/bin/bash

source ./util.sh

if [[ ! $1 ]]
then
    echo -e "\n${YELLOW}Please run the program from ${RED}dbms.sh ${YELLOW}file\n${NC}"
    exit
fi


read -p "Enter your table name: " table_name
error=`validate_name $table_name`
if [ $? -eq 1 ]
then
    # Returns Error
    echo -e "\n${RED}>>>${YELLOW}Table name $error${RED}<<<${NC}\n"
    exit
fi

DB=$1/$table_name

if [ ! -f $DB ]
then
    # Returns Error
    echo -e "\n${RED}Table does NOT exist${NC}\n"
    exit
fi

SCHEMA=$1/.$table_name
primary_key_column=`head -n 3 $SCHEMA | tail -n 1`

#echo $primary_key_column


while [ true ]
do
    select choice in update_column back
    do
        case $choice in 
            update_column)
                column_name=`awk -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } NR==1 { print $primary_key_column;exit}' $SCHEMA`
                type=`awk -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } NR==2 { print $primary_key_column;exit}' $SCHEMA`                        
                echo -e "\nEnter the value of ${YELLOW}the primary key ($column_name)${NC} that its type is ${YELLOW}($type)${NC}"
                read primary_key

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
                    if [[ $columns =~ ^[0-9]+$ ]]
                    then
                        if [[ $columns > $num_of_columns || $columns < 0 ]]
                        then
                            echo -e "\n${RED}Number of columns must be between 1 and $num_of_columns${NC}\n"
                            continue
                        else
                            break
                        fi
                    else
                        echo -e "\n${RED}Number of columns must be integer${NC}\n"
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
                        
                        if [[ $column_num == $primary_key_column ]]
                        then
                            echo -e "\n${YELLOW}Be careful this column is your primary-key${NC}\n"
                        fi
                        
                        column_name=`awk -v column_num=$column_num 'BEGIN { FS=":" } NR==1 { print $column_num}' $SCHEMA`
                        type=`awk -v column_num=$column_num 'BEGIN { FS=":" } NR==2 { print $column_num}' $SCHEMA`                        
                        echo -e "\nEnter the value of column ${YELLOW}$column_name${NC} that its type is ${YELLOW}($type)${NC}"
                        read column_value
                        
                        #Check if the primary key is exist
                        if [[ $column_num == $primary_key_column ]]
                        then
                            if [[ `awk -v column_value=$column_value -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } column_value == $primary_key_column { print "1"}' $DB` ]]
                            then
                                echo -e "\n${RED}primary key must be uniqe this value is already exist${NC}\n"
                                exit
                            fi
                        fi


                        # if [[ $column_num == $primary_key_column ]]
                        # then
                        #     row_nums=`cat $DB | wc -l`
                            
                        #     for ((i=1;i<=$row_nums;i++))
                        #     do
                        #         pri_key_val=`awk -v i=$i -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } NR==i { print $primary_key_column}' $DB`
                                
                        #         if [[ $column_value == $pri_key_val ]]
                        #         then
                        #             echo -e "\n${RED}primary key must be uniqe this value is already exist${NC}\n"
                        #             exit
                        #         fi
                        #     done
                        # fi

                        error=`validate_table_data $type $column_value`
                        if [ $? -eq 1 ]
                        then
                            # Returns Error
                            echo -e "\n${RED}>>>${YELLOW}$error${RED}<<<${NC}\n"
                            continue
                        else
                            break
                        fi


                        # case $type in
                        #     int)
                        #         if [[ ! $column_value =~ ^[+-]?[0-9]+$ ]]; then
                        #             echo -e "\n${RED}Value must be integer.${NC}\n"
                        #             continue
                        #         else
                        #             break
                        #         fi
                        #     ;;
                        #     float)
                        #         if [[ ! $column_value =~ ^[+-]?[0-9]+[.][0-9]*$ ]]; then
                        #             echo -e "\n${RED}Value must be float.${NC}\n"
                        #             continue
                        #         else
                        #             break
                        #         fi
                        #     ;;
                        #     string)
                        #         echo -e "\n${GREEN}Your value added as a string${NC}\n"
                        #         break
                        #     ;;
                        # esac
                    done
                    
                    awk -v row=$row -v i=$column_num -v v=$column_value 'BEGIN { FS=OFS=":" } NR==row { $i = v } 1' \
                    $DB > ./databases/tmp && rm $DB && mv ./databases/tmp $DB
                done
            ;;
            back)
                exit
            ;;
        esac
    done
done