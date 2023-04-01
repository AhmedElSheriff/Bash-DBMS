#!/bin/bash

select choice in "Create table" "List tables" "Drop table" exit
do
	case $choice in
		"Create table")
			./create-table.sh ;;
		"List tables")
			./list-tables.sh ;;
		"Drop table")
			./drop-table.sh ;;
		exit)
			exit;;
	esac
done
