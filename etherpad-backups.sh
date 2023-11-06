#!/bin/bash
# Incremental backuping of all your etherpads
# Using symbolic links to free storage space
# Adapt "u" varirable with username and $W_DIR 1st, and if you move to new home
# Passing "update" as an argument will force updating
# I.E. re-downloading files

#### User config : EDIT ME ! ####
# Your sources are stored in an associative array.
# In shell we assign it with "array[key]=value"
# Each element in that array stores a name and a
# space-separated "server" + "pads" lists, hence the name "serpads".
# It must be called "serpads[server-name]" where server-name is a name
# you chose and that corresponds to the server, and will be the name 
# of the folder storing its pads in their own subfolders.
# The 1st strig must be the complete server address ending with /p/, and
# the other ones are the different pads you want to backup from that server.
# Examples : ['example_server']="https://example-server.org/p/ pad1 example2"
#  			 ['other-server']="https://other-server.org/p/ 1dap exampleZ"
declare -A serpads=(
	['example_server']="https://example-server.org/p/ pad1 example2"
	['other-server']="https://other-server.org/p/ 1dap exampleZ"
)
# Filetype needed : "odt" or "pdf"
type="odt"
# Enable or disable symbolic links. 
# Useful if can't/won't get "odt2txt".
# Default : yes <>  symbolic links
#			no  <> always keep new files
#					# takes more disk space
symlinks="yes"
# Default, only set to no in case no odt2txt command available 
txtable="yes"
# Replace by real username and password (sudo) if start by cron/anacron (so root)
#u=""
#pw=""


# Paths, adapt as you wish
# /!\ keep the ending '/' !
W_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Latest folder, to always have all your new version at hand !
LATEST="${W_DIR}/latest/"
# And if you put (some of) those settings in config.txt filen
# uncomment so it overwrites above config.
source "${W_DIR}/config.txt"
#### End of user config ####


## Init, Help & Args // TO BE CONTINUED/UPDATED
if [ "${1-}" == "-h" ]; then echo "1st arg = auto/manual/update/-h comment text,\n update : won't symlink but dl all files"; exit; fi
if [ ! -z "${1-}" ]; then mode="$1"; else mode="manual"; fi
set -o errexit
set -o nounset
set -o pipefail

LOG_FILE="${W_DIR}/backup-pads.log"
touch "$LOG_FILE"
export DATE="$(date '+%Y-%m-%d')"
PRV_DATE="$(tail -n1 $LOG_FILE | cut -c -10)"
if "$PRV_DATE" == ""; then PRV_DATE=null; fi
NEW_SUFX="_${DATE}.${type}"
continue="y"

# Make a folder (if not already there)
function mkdir_s {
	if [ ! -d "$1" ]; then mkdir -p "$1"; fi
}
# Make a folder (if not already there) and move into it
function mkcd {
	mkdir_s "$1"
	cd "$1"
}
## In case odt2txt isn't available
if [ "$symlinks" == "yes" ] && [ $type == "odt" ] && [ $(command -v otd2txt >/dev/null 2>/dev/null) ] ; then
	txtable="no"; echo "odt2txt is needed to get odt files !"
	echo "You can quit now to install it and relaunch the script,"
	echo 'or modify the script with symlinks="no" to disable this check.'
	read -p "Continue ?  y/n" continue
	if [ "$continue" != "[Yy]*" ] ; then exit 1; fi
fi

## readlink finds the file pointed to by a link
## From : Charles Duffy 
## https://stackoverflow.com/questions/31596363/how-to-recursively-resolve-symlinks-without-readlink-or-realpath/31596978#31596978
# define the best readlink function available for this platform
if command -v readlink >/dev/null 2>/dev/null; then
  # first choice: Use the real readlink command
  readlink() {
    command readlink -- "$@"
  }
elif find . -maxdepth 0 -printf '%l' >/dev/null 2>/dev/null; then
  # second choice: use GNU find
  readlink() {
    local ll candidate >/dev/null 2>&1 ||:
    if candidate=$(find "$1" -maxdepth 0 -printf '%l') && [ "$candidate" ]; then
      printf '%s\n' "$candidate"
    else
      printf '%s\n' "$1"
    fi
  }
elif command -v perl >/dev/null 2>/dev/null; then
  # third choice: use perl
  readlink() {
    local candidate ||:
    candidate=$(target=$1 perl -le 'print readlink $ENV{target}')
    if [ "$candidate" ]; then
      printf '%s\n' "$candidate"
    else
      printf '%s\n' "$1"
    fi
  }
else
  # fourth choice: parse ls -ld
  readlink() {
    local ll candidate >/dev/null 2>&1 ||:
    ll=$(LC_ALL=C ls -ld -- "$1" 2>/dev/null)
    candidate=${ll#* -> }
    if [ "$candidate" = "$ll" ]; then
      printf '%s\n' "$1"
    else
      printf '%s\n' "$candidate"
    fi
  }
fi
# readlink_recursive find latest link when links poins to links in a chain
readlink_recursive() {
    local path prev_path oldwd found_recursion >/dev/null 2>&1 ||:
    oldwd=$PWD; path=$1; found_recursion=0
    while [ -L "$path" ] && [ "$found_recursion" = 0 ]; do
        if [ "$path" != "${path%/*}" ]; then
          cd -- "${path%/*}" || {
            cd -- "$oldwd" ||:
            echo "ERROR: Directory '${path%/*}' does not exist in '$PWD'" >&2
            return 1
          }
          path=${PWD}/${path##*/}
        fi
        path=$(readlink "$path")
        if [ -d "$path" ]; then
          cd -- "$path"
          path=$PWD
          break
        fi
        if [ "$path" != "${path%/*}" ]; then
          cd -- "${path%/*}" || {
            echo "ERROR: Could not traverse from $PWD to ${path%/*}" >&2
            return 1
          }
          path=${PWD}/${path##*/}
        elif [ "$PWD" != "$oldwd" ]; then
          path=${PWD}/$path
        fi
        for prev_path; do
          if [ "$path" = "$prev_path" ]; then
            found_recursion=1
            break
          fi
        done
        set -- "$path" "$@" # record path for recursion check
    done
    if [ "$path" != "${path%/../*}" ]; then
      cd "${path%/*}" || {
        echo "ERROR: Directory '${path%/*}' does not exist in $PWD" >&2
        return 1
      }
      printf '%s\n' "$PWD/${path##*/}"
    else
      printf '%s\n' "$path"
    fi
    cd -- "$oldwd" ||:
}
# Thanks Charles, back to our etherpad shenanigans...

# This function links to older backup versions if they are the same
# Requires odt2txt installed to compare odt backups
# Delete previous backup if it was already a symlink to an identic backup
cmpToLn(){
	test "$(ls | wc -w)" -lt 2 && return 0
	old=$(ls -t *."$type"|head -n2|tail -n1)
	new=$(ls -t *."$type"|head -n1)
	oldest=$(readlink_recursive "$old")
	if [ "$oldest" != "$old" ] ; then
		rm "$old"; old="$oldest"; echo "$old link deleted. (Both $old and $new points to $oldest)"
	fi
	case "$type" in
		"odt") # .odt file
			[ "$txtable" == "no" ] && echo "Kept $new, (txtable=no)" ; return 0
			for f in "$old" "$new"; do odt2txt "$f" --output="$f".txt; done
			if `cmp -s "$old".txt "$new".txt`; then
				ln -fs "$old" "$new";
				echo "$new linked to $old, as they are the same"
				rm "$old".txt "$new".txt
			else
				echo "$new is a new version"
			fi
		;;
		"pdf") # .pdf file
			if `cmp -s "$old" "$new"`; then
				ln -fs "$old" "$new";
				echo "$new linked to $old, as they are the same"
			else
				echo "$new is a new version"
			fi
		;;
		*) echo "Error : filetype $type not available, only odt or pdf. Please correct setting."
	esac
}

## Main
mkdir_s "${LATEST}"
if ( `pwd` != "$W_DIR" ); then mkcd "$W_DIR"; fi
## Update ? (For logs purposes, no big deal)
if [ "${PRV_DATE}" == "${DATE}" ] && [ "${mode}" != "update" ] ; then
	echo "${DATE} backup already done, exiting..."
	exit 1
#elif [ ! "${PRV_DATE}" ]; then #!!
#	echo "No previous backup found"
#	echo "Check log $LOG_FILE"
#	continue=$(read -p "Continue (Y/n)")
fi
## Actual download loops
if [ "$continue" != "[Nn]"* ]; then
	if [ "$mode" == "update" ]; then
	    echo "Updating ${DATE} backups ..."
	else
	    echo "Creating ${DATE} backups ..."
	fi
	## Download with wget
	for nom in "${!serpads[@]}"; do
		mkcd "$nom"
	    IFS=' ' read -a serpad <<< "${serpads[$nom]}"
	    server="${serpad[0]}"
	    l_serpad="${#serpad[*]}"
	    declare -a pads=()
	    for (( i=1; i<$l_serpad; i++ )); do
			pads+=("${serpad[$i]}")
			echo "$pads"
	    done
	    for pad in ${pads[*]} ; do
			mkcd "$pad"
			wget "${server}${pad}/export/${type}" --content-disposition -O "${pad}${NEW_SUFX}"
			# Compare previous with new backup, keep that last one only if different
			if [ "$symlinks" == "yes" ] ; then cmpToLn; fi
			# link new pad in latest_pads folder
			ln -fs "${W_DIR}/${nom}/${pad}/${pad}${NEW_SUFX}" "${LATEST}${pad}"."$type" && echo "$pad linked in $LATEST"
			cd .. && sleep 10
		done
		cd ..
	done
    cd ..
else
	echo "No actions taken, exiting"
	exit 1
fi

# Give file ownership to user, useful if started by anacron/cron
if [ "$(whoami)" == "root" ] ; then 
    chown $u:$u -R $W_DIR
else
    sudo chown $u:$u -R $W_DIR
fi

## Log / echo ?
if [ "$PRV_DATE" != "$DATE" ]; then echo "$DATE : $mode donwloads complete !" >> ${LOG_FILE};fi
# Notify job complete
if [ "$(whoami)" != "root" ] ; then 
    notify-send "All pads have been downloaded !"
fi
echo  "All pads have been downloaded !"
