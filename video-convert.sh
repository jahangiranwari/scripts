#!/bin/bash 

#
# Script to convert videos generated by Canon camcorder and Panasonic camera
#

shopt -s nocasematch
set -eE
set -o pipefail

# Store Source and Destination folder arguments
SRC_DIR=
DEST_DIR=
VID_RES=
CRF=
FORMAT='mov|mp4|mts'
TYPE=
AUDIO_FREQ=
AUDIO_BIT_RATE=
ADDITIONAL_OPTIONS=
OUTPUT_FORMAT='mp4'

#
# For each file that we are looking to convert the following steps are executed:
#   1) Extract the timestamp from the source file. This is to assist with adding watermark later if needed.
#   2) Using FFmpeg tool we convert the Canon AVHCD format to x264 format. The timestamp of the source file is stored in the description meta tag of converted file.
#
usage()
{
cat << EOF
usage: $0 options

OPTIONS:
   -a   Audio Frequency (44100, 28000)
   -b	Audio Bit Rate (64, 96, 128, 192, 360)
   -c   Constant Ratefactor(CRF) level
   -d   Destination directory
   -f   Source Format (mts, mov, mp4)
   -h   Usage
   -r	Video Resolution
   -s   Source directories
   -t   Type of source video device (camcorder, camera)
EOF
}

set_default_params()
{
	audioFreq=`if [[ ! -z $AUDIO_FREQ ]]; then echo $AUDIO_FREQ; else echo '44100'; fi`
	audioBR=`if [[ ! -z $AUDIO_BIT_RATE ]]; then echo $AUDIO_BIT_RATE; else echo '128'; fi`
	videoRes=`if [[ ! -z $VID_RES ]]; then echo $VID_RES; else echo '640x352'; fi`
	crf=`if [[ ! -z $CRF ]]; then echo $CRF; else echo '25'; fi`
}

# 'file' argument is passed by the while loop
convert()
{
	cd
	local timestamp=`stat -c "%y" "$file"  | cut -d'.' -f1 | xargs -I "{}" date -d "{}" +"%d.%b.%Y %r"`

	local srcFileDir="${file%/*}"			# Strip filename
	local srcFilename="${file##*/}" 		# Strip path before filename
	local srcExtension="${file##*.}" 		# Extract extension
	srcFilename="${srcFilename%.*}"			# Strip extension

	local destFilename=`if 	 [[ ! -z "$DEST_DIR" ]]; then echo "$DEST_DIR/${srcFilename}.mp4"
						elif [[ ! $OUTPUT_FORMAT =~ $srcExtension ]]; then echo "$srcFileDir/${srcFilename}.mp4"
						elif [[ $OUTPUT_FORMAT =~ $srcExtension ]];   then echo "$srcFileDir/${srcFilename}-converted.mp4"
						fi`

	if [[ $TYPE ==  'camcorder' ]]
	then
		
		ffmpeg -i "$file" -vcodec copy -acodec copy \
				-metadata description="Timestamp = $timestamp" \
				-metadata comment="Timestamp = $timestamp" \
				-y "$destFilename" 
	else
	
		ffmpeg 	-i "$file" \
				-vcodec libx264 \
				-vpre special \
				-s $videoRes \
				-threads 0 \
				-acodec libmp3lame \
				-ab $audioBR"k" \
				-ar $audioFreq \
				-async $audioFreq \
				-ac 2 \
				-crf $crf \
				$ADDITIONAL_OPTIONS \
				-metadata description="Timestamp = $timestamp" \
				-metadata comment="Timestamp = $timestamp" \
				-y "$destFilename"
	
	fi	
	
	touch -m -d "$(stat -c %y "$file")" "$destFilename"	# Save the original creation/modification data					

}


convert_videos()
{
	#find "$SRC_DIR" -type f  \( -iname "*.mts" -o -iname "*.mp4" \) -print | while read file; do mts_convert "$file"; done
	find "$SRC_DIR" -type f  \( ! -iname "MVI*" \) -regextype posix-egrep -iregex ".*.($FORMAT)" -print | while read file; do convert; done
}

canon_camcorder()
{
	audioFreq='44100'
	audioBR='128'
	#videoRes='640x352'
	#ADDITIONAL_OPTIONS="-aspect 16:9"
	crf=21
	FORMAT=$FORMAT"|mts"
	videoRes='1280x720'
	convert_videos
}

panasonic_camera()
{
	audioFreq='44100'
	audioBR='96'
	videoRes='320x240'
	crf=25
	FORMAT=$FORMAT"|mov"
	convert_videos
}


#Process the arguments
while getopts a:b:c:s:d:hr:f:t: opt
do
   case "$opt" in
        a) 	AUDIO_FREQ="$OPTARG"
            ;;

        b) 	AUDIO_BIT_RATE="$OPTARG"
            ;;

        c)	CRF="$OPTARG"
            ;;

        d) 	DEST_DIR="$OPTARG"
            ;;

        f) 	FORMAT="$OPTARG"
            ;;

        r) 	VID_RES="$OPTARG"
            ;;

        s) 	SRC_DIR="$OPTARG"
            ;;

        t)	TYPE="$OPTARG"
            ;;

      h|?)  usage
            ;;
   esac
done
shift $(($OPTIND - 1))

if [[ -z $SRC_DIR ]]
then
	echo "Please provide source directory"
	exit 1;
fi

if [[ -z $DEST_DIR ]]
then
	echo "Please provide destination directory"
	exit 1;
fi

case $TYPE in

  camcorder)  canon_camcorder
              ;;

     camera)  panasonic_camera
              ;;

          *)  set_default_params
              convert_videos
              ;;
esac



