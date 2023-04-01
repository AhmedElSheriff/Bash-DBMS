#!/bin/bash

DB=databases

echo " \"Spaces should be avoided and replace with _\" "
read -p "Enter your table name: " table_name

while [[ true ]]
do
if [[ ! $table_name ]]
then
	echo "Table name can not be NULL"
	read -p "Enter your table name: " table_name
	continue
fi

if [[ ${table_name:0:1} == [0-9] ]]
then
	echo "Table name should not start with number"
	read -p "Enter your table name: " table_name
	continue
fi

if [[ $table_name == *[" "'!'\/@#\$%^\&*()+]* ]]
then
        echo "Table name should not contain spicial character"
        read -p "Enter your table name: " table_name
	continue
fi
break
done

cd $DB
if [[ -f $table_name ]]
then
	echo "file is already exist"
else
	touch $table_name
fi


i=0
while [ true ]
do
read -p "Enter your columns names sperated by enter and press ctrl+d to end. " Input
#When ^D is used, read ends up with the exit code "1"

if [[ $? == 1 ]]

then
     echo "[Ctrl+D] is captured"
     break
fi

cols[i]=$Input
i=$((i+1))

done

#for item in ${cols[@]}
#do
#	echo $item
#done
#echo ${cols[*]}

printf -v joined '%s:' "${cols[@]}"
echo "${joined%:}" >> $table_name


i=0
select choice in int float string exit
do
case $choice in
int)
types[i]=int
i=$((i+1))
;;
float)
types[i]=float
i=$((i+1))
;;
string)
types[i]=string
i=$((i+1))
;;
exit)
break
;;
esac
done

printf -v joined '%s:' "${types[@]}"
echo "${joined%:}" >> $table_name

