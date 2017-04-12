#!/usr/bin/env bash

COLOR='#4CAF50'
STRARR=('makepkg,\nnot war' \
	'make install,\nnot war' \
	'If you can read this,\nxorg is still running')

MAXINDEX=$((${#STRARR[@]}-1))

# $1 contains the path to the input background wallpaper
if [ -z $1 ]; then
	echo 'You must pass the background wallpaper as a parameter'
	exit 1
fi
if ! [ -f $1 ]; then
	echo 'File does not exist!'
	exit 1
fi

STR=${STRARR[`shuf -i 0-$MAXINDEX -n 1`]}

convert $1 -gravity south -stroke $COLOR -fill $COLOR -font Fira-Mono -pointsize 32 -annotate +0+250  "$STR" /tmp/wallpaper.png
