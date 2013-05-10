#!/bin/bash

#
# Script to encrypt files using 7-Zip
#

FILE_PWD="replace_with_secret_pwd"
SRC_DIR=
DST_DIR=

usage()
{
cat << EOF
usage: $0 options

This script encrypts files.

OPTIONS:
   -d      Destination directory
   -h      Help
   -s      Source directories
EOF
}


encrypt_file()
{
	filename=$(basename "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	
	echo Encrypting and Zipping $filename
	7z a -v2047m -t7z -mx9 -p$FILE_PWD -mtc=on -mhe=on $DST_DIR/$filename.7z $file
}

encrypt_files()
{
	find "$SRC_DIR" -type f -print | while read file; do encrypt_file; done
}


#Process the arguments
while getopts s:d:hz opt
do
   case "$opt" in
		s) 	SRC_DIR="$OPTARG"
			;;
			
		d) 	DST_DIR="$OPTARG"
			;;
			
	   h|?) usage
			;;
   esac
done
shift $(($OPTIND - 1))

if [[ -z $SRC_DIR ]]
then
	echo "Please provide a source directory"
	exit 1;
fi

if [[ -z $DST_DIR ]]
then
	echo "Please provide a destination directory"
	exit 1;
fi

encrypt_files

