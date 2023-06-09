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
                # Get the name of primary key column
                column_name=`awk -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } NR==1 { print $primary_key_column;exit}' $SCHEMA`
                # Get the type of primary key column
                type=`awk -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } NR==2 { print $primary_key_column;exit}' $SCHEMA`                        
                # Enter the primary key value
                echo -e "\nEnter the value of ${YELLOW}the primary key ($column_name)${NC} that its type is ${YELLOW}($type)${NC}"
                read primary_key

                row=`awk -v primary_key=$primary_key -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } \
                $primary_key_column == primary_key { print NR ;exit} ' $DB`
                #echo $row
                
                #Check if the primay key is exist or not
                if [[ ! $row ]]
                then
                    echo -e "\n${RED}This primary key is not exist${NC}\n"
                    break
                fi

                while [ true ]
                do
                    read -p "Enter the numbers of columns you need to update seperated by comma (,): " colms
                    num_of_columns=`head -n 2 $SCHEMA | tail -n 1 | tr ":" " " | wc -w`
                    cols_formatted=${colms//,/ }

                    if [[ ! $colms =~ ^[0-9]+[,0-9]*$ ]]
                    then
                        echo -e "\n${RED}The value must be column numbers seperated by comma${NC}\n"
                        continue
                    fi
                    break
                done
                
                for val in $cols_formatted
                do
                    if (( $val > $num_of_columns ))
                    then
                        echo -e "\n${RED}your columns values should be between 0 and $num_of_columns${NC}\n"
                        #break from for loop                                
                        break 2
                    fi
                done

                for col in $cols_formatted
                do  
                    while [ true ]
                    do
                        
                        if [[ $col == $primary_key_column ]]
                        then
                            echo -e "\n${YELLOW}Be careful this column is your primary-key${NC}\n"
                        fi
                        # Get the name of each column
                        column_name=`awk -v column_num=$col 'BEGIN { FS=":" } NR==1 { print $column_num}' $SCHEMA`
                        # Get the type of each column
                        type=`awk -v column_num=$col 'BEGIN { FS=":" } NR==2 { print $column_num}' $SCHEMA`                        
                        # input the value that the column will update to
                        echo -e "\nEnter the value of column ${YELLOW}$column_name${NC} that its type is ${YELLOW}($type)${NC}"
                        read column_value
                        
                        #Check if the primary key is exist
                        if [[ $col == $primary_key_column ]]
                        then
                            if [[ `awk -v column_value=$column_value -v primary_key_column=$primary_key_column 'BEGIN { FS=":" } column_value == $primary_key_column { print "1"}' $DB` ]]
                            then
                                echo -e "\n${RED}primary key must be uniqe this value is already exist${NC}\n"
                                continue
                            fi
                        fi

                        error=`validate_table_data $type $column_value`
                        if [ $? -eq 1 ]
                        then
                            # Returns Error
                            echo -e "\n${RED}>>>${YELLOW}$error${RED}<<<${NC}\n"
                            continue
                        else
                            break
                        fi
                    done
                    
                    awk -v row=$row -v i=$col -v v=$column_value 'BEGIN { FS=OFS=":" } NR==row { $i = v } 1' \
                    $DB > ./databases/tmp && rm $DB && mv ./databases/tmp $DB
                done
                break
            ;;
            back)
                exit
            ;;
        esac
    done
done