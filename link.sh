#!/usr/bin/env bash

# This script interactively copies every source to its target, as defined in the link.conf file.

ARGS="hc:ynb"
CONFIGFILE="link.conf"
ALWAYSINSTALL=false
NEVERINSTALL=false
BACKUP=false
EXPLICIT_INSTALL=false
INSTALL_LIST=""
HELPMSG='This script interactively creates symlinks.

Usage:
-h: Show help
-c FILE: The configuration file to use. Defaults to link.conf
-y: Always install.
-n: Dry run. This never installs anything, just see what happens.
-b: Backup existing files before overwriting. Disabled by default.

If you want to install files by name, just pass them as trailing argument.
'

WHITE='\e[0m'
RED='\e[01;31m'
GREEN='\e[01;32m'
YELLOW='\e[01;33m'
BLUE='\e[01;34m'
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

# trailing arguments
shift "$(( $OPTIND - 1 ))"
INSTALL_LIST="$(echo "$@" | sed 's/\s\+/\n/g')"
if ! [[ -z "$INSTALL_LIST" ]]; then
	EXPLICIT_INSTALL=true
fi

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
	# skip if not in explicit install list
	if "$EXPLICIT_INSTALL"; then
		FOUND=false
		for expl in $INSTALL_LIST; do
			if [[ "$expl" == "$SOURCE" ]]; then
				FOUND=true
				break
			fi
		done
		if ! "$FOUND"; then
			continue
		fi
	fi

	echo -e "\nAttempting to install $BLUE$SOURCE$WHITE at $RED$DEST$WHITE"
	if [ -e "$DEST" ]; then
		echo -e "${YELLOW}WARNING$WHITE: $RED$DEST$WHITE already exists!"
		if "$BACKUP"; then
			BACKUPFILE="$DEST.backup"
			echo -e "Creating backup of $RED$DEST$WHITE as $GREEN$BACKUPFILE$WHITE"
			cp -r "$DEST" "$BACKUPFILE" || echo -e "${RED}ERROR$WHITE: Could not create backup"
		fi
	fi
	answer="y"
	if ! "$ALWAYSINSTALL"; then
		echo -e "${GREEN}Install?$WHITE ((y)es, (N)o, go (b)ack) \c"
		read -r answer
	fi
	if [ "$answer" == "b" ]; then
		i=$((i - 2))
	fi
	if "$NEVERINSTALL"; then
		answer="n"
	fi
	if [ "$answer" == "y" ]; then
		if ! { [ -e "$DEST" ] || [ -h "$DEST" ]; }; then
			mkdir -p "$DEST" || echo -e "${RED}ERROR$WHITE: No permission in this directory"
		fi
		rm -r "$DEST" || echo -e "${RED}ERROR$WHITE: No permission to delete this file"
		# finally install
		ln -s "$PWD/$SOURCE" "$DEST" || echo -e "${RED}ERROR$WHITE: Could not create symlink"
	else
		echo "Skipping..."
	fi
done
