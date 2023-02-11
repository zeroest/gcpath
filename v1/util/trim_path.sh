
#!/bin/bash

if [ -z $1 ] || ! [ -f "./$1" ]
then
  echo "Please insert path file"
  exit
fi

if [ -z $2 ] 
then
  echo "Please insert result file name"
  exit
fi

> "$2"
awk '{ print substr($8,2,length($8)-3) }' $1 >> "$2"

