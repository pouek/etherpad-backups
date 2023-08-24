#!/bin/bash
# Incremental backuping of all your etherpads
# Using symbolic links to free storage space
# Adapt $user and $W_DIR 1st, and if you move to new home
# Passing "update" as an argument will force updating

## User set up : SET ME UP !
# Space-separated pads list
pads="pad1 example2"
# Etherpad server, ending with "/p/"
server="https://example-server.org/p/"
# Filetype needed : "odt" or "pdf"
type="odt"
# Replace by real username if start by cron/anacron
u=$USER
# Paths, adapt as you wish
W_DIR="/home/${u}/etherpads-backups/"
# Latest folder, to always have all your new version at hand !
# ( The missing '/' is already in ${W_DIR} )
LATEST="${W_DIR}latest/"

## Init, Help & Args // TO BE CONTINUED/UPDATED
if [ "${1-}" == "-h" ]; then echo "1st arg = auto/manual/update/-h comment text,\n update : won't symlink but dl all files"; exit; fi
if [ ! -z "${1-}" ]; then mode="$1"; else mode="manual"; fi
set -o errexit
set -o nounset
set -o pipefail

# Check parameters
echo "check if $W_DIR directory ok..."
test -d $W_DIR || echo "Update script with username and paths..."

LOG_FILE="${W_DIR}bakup-pads.log"
touch "$LOG_FILE"
export DATE="$(date '+%Y-%m-%d')"
PRV_DATE=$(tail -n1 $LOG_FILE | cut -c -10)
NEW_SUFX="_${DATE}.odt"
continue="y"

# This function links to older version if they are the same (and delete useless files)
# Requires odt2txt installed
cmpToLn(){
old=$(ls -t|head -n2|tail -n1)
new=$(ls -t|head -n1)
if [[ "$type" == "odt" ]]; then
    for f in "$old" "$new"; do odt2txt "$f" --output="$f".txt; done
    if `cmp -s "$old".txt "$new".txt`; then
        ln -fs "$old" "$new";
        echo "$new linked to $old, as they are the same"
    else
        echo "$new is a new version"
    fi
    rm "$old".txt "$new".txt
else # PDF filetype
    if `cmp -s "$old" "$new"`; then
        ln -fs "$old" "$new";
        echo "$new linked to $old, as they are the same"
    else
        echo "$new is a new version"
    fi
}

## Main
cd "$W_DIR"
## Update ? (For logs purposes, no big deal)
if [ "${PRV_DATE}" == "${DATE}" ] && [ "${mode}" != "update" ] ; then
	echo "${DATE} backup already done, exiting..."
	exit 1
elif [ ! "${PRV_DATE}" ]; then #!!
	echo "No previous backup found"
	echo "Check log $LOG_FILE"
	continue=$(read -p "Continue (Y/n)")
fi
## Actual download loops
if [ "$continue" != "n" ] && [ "$continue" != "N" ]; then
	if [ "$mode" == "update" ]; then
	    echo "Updating ${DATE} backups ..."
	else
	    echo "Creating ${DATE} backups ..."
	fi
	## Download with wget
	for pad in $pads; do
	    if [ ! -d $pad ]; then mkdir $pad;fi
	    cd $pad
	    wget "${server}${pad}/export/${type}" --content-disposition
	    mv "${pad}.odt" "${pad}""${NEW_SUFX}"
	    # Working on a way to delete useless links to links to links ... Uncomment to test, develop, ...
	    #cmpToLn
	    # link new pad in latest_pads folder
	    if [ ! -d ${LATEST} ]; then mkdir ${LATEST};fi
	    ln -fs "${W_DIR}""${pad}"/"${pad}""${NEW_SUFX}" "${LATEST}""${pad}".odt && echo "$pad linked in $LATEST"
	    cd .. && sleep 10
	done
    cd ..
else
	echo "No actions taken, exiting"
	exit 1
fi

# Give file ownership to user, useful if started by anacron/cron
sudo chown $USER:$USER -R $W_DIR

## Log / echo ?
#if [ "$PRV_DATE" != "$DATE" ]; then echo "$DATE : $mode donwloads complete !" >> ${LOG_FILE};fi
# Notify job complete
notify-send "All pads have been downloaded !"
echo  "All pads have been downloaded !"
