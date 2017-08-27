#!/usr/bin/env bash

# This script interactively copies every source to its target, as defined in the install.config file.

ARGS="hc:ynb"
CONFIGFILE="install.conf"
ALWAYSINSTALL=false
NEVERINSTALL=false
BACKUP=false
HELPMSG='This script interactively creates symlinks.

Usage:
-h: Show help
-c FILE: The configuration file to use. Defaults to install.conf
-y: Always install.
-n: Dry run. This never installs anything, just see what happens.
-b: Backup existing files before overwriting. Disabled by default.
'

WHITE="\e[0m"
RED="\e[01;31m"
GREEN="\e[01;32m"
YELLOW="\e[01;33m"
BLUE="\e[01;34m"
# Exit on error
set -e
error() {
	echo -e "$RED$*$WHITE" 1>&2
	exit 1
}

# First get options passed from CLI

while getopts $ARGS OPT; do
	case $OPT in
	h)
		printf "%s" "$HELPMSG"
		exit 0
		;;
	c)
		CONFIGFILE=$OPTARG
		if ! [ -f "$CONFIGFILE" ]; then
			error "$OPTARG is not a file"
		fi
		;;
	y)
		ALWAYSINSTALL=true
		;;
	n)
		ALWAYSINSTALL=true
		NEVERINSTALL=true
		;;
	b)
		BACKUP=true
		;;
	:)
		error "Error: -$OPT requires an argument"
		;;
	?)
		error "Error: Unknown option -$OPT"
		;;
	esac
done

# Now that we have finished parsing the CLI args, continue with stowing everything

# First load the config file
SOURCES=$(cut -d ' ' -f1 "$CONFIGFILE")
DESTS=$(cut -d ' ' -f2 "$CONFIGFILE")
for ((i = 1; i <= $(echo "$SOURCES"| wc -l); i++)); do
	# extract source and destination
	SOURCE=$(printf "%s" "$SOURCES"| sed $i"q;d")
	DEST=$(printf "%s" "$DESTS"| sed $i"q;d")
	# expand ~ and $HOME
	DEST="${DEST/#\~/$HOME}"
	DEST="${DEST/#'$HOME'/$HOME}"
	echo -e "Attempting to install $BLUE$SOURCE$WHITE at $RED$DEST$WHITE"
	if [ -e "$DEST" ]; then
		echo -e "${YELLOW}WARNING$WHITE: $RED$DEST$WHITE already exists!"
		if "$BACKUP"; then
			BACKUPFILE="$DEST.backup"
			cp -r "$DEST" "$BACKUPFILE"
			echo -e "Created backup of $RED$DEST$WHITE as $GREEN$BACKUPFILE$WHITE"
		fi
	fi
	answer="y"
	if ! "$ALWAYSINSTALL"; then
		echo -e "${GREEN}Install?$WHITE ((Y)es, (n)o) \c"
		read -r answer
	fi
	if "$NEVERINSTALL"; then
		answer="n"
	fi
	if [ "$answer" == "n" ]; then
		echo "Skipping..."
	else
		if ! [ -e "$DEST" ]; then
			mkdir -p "$DEST"
		fi
		rm -r "$DEST"
		# finally install
		ln -s "$PWD/$SOURCE" "$DEST"
	fi
done
