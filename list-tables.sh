#!/bin/bash

DB=database
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

exit) exit
esac
done
