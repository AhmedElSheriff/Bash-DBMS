#!/bin/bash

DB=database
cd $DB

read -p "Enter your table name: " table_name

if [[ -f $table_name ]]
then
        rm -i $table_name
else
        echo Table is not exist
fi
