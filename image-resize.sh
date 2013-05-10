#!/bin/bash

SRC_DIR=
OUTPUT_DIR=
TMP_DIR=
CREATE_ZIP=

usage()
{
cat << EOF
usage: $0 options

This script resizes images to 800x600 and creates a zip file.

OPTIONS:
   -d      Destination directory
   -h      Help
   -s      Source directories
   -z      Create Zip file
EOF
}

set_default_params()
{
	TMP_DIR=$OUTPUT_DIR/`date +"%d.%b.%Y"`
	[[ ! -d $TMP_DIR ]] &&  mkdir -p $TMP_DIR
}

resize_images()
{
	set_default_params 
	find "$SRC_DIR" -type f  \( -iname "*.jpg" \)  | while read file; do filename=`basename "$file"`; perl epeg.pl  "$file" "$TMP_DIR/$filename";  done
	create_zip_file
}

# If -z flag is set then create a zip file
create_zip_file()
{
	[[ ! -z $CREATE_ZIP &&  ! -z `ls -A $TMP_DIR` ]] && zip -9 -j $TMP_DIR.zip $TMP_DIR/*
	exit 0
}

#Process the arguments
while getopts s:d:hz opt
do
   case "$opt" in
		s) 	SRC_DIR="$OPTARG"
			;;
			
		d) 	OUTPUT_DIR="$OPTARG"
			;;
			
		z)	CREATE_ZIP=1
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

if [[ -z $OUTPUT_DIR ]]
then
	echo "Please provide a destination directory"
	exit 1;
fi

resize_images

#for dir in "$@"
#do
    ##mogrify -path $TMP_DIR -resize '800x600>' "$dir*.{jpg,JPG}"
    #find "$dir" -type f  \( -iname "*.jpg" \) |  xargs -I {} mogrify -path $TMP_DIR -resize '800x600>' "{}"
#done
