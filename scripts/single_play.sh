#!/bin/bash

# This script saves or restores the SINGLE status in a playlist (=folder) and enables/disables 
# single mode according to the folder.conf of the current folder/playlist
# Usage:
# Enable single mode for folder: ./single_play-sh -c=enablesingle -v=foldername_in_audiofolders
# Disable single mode for folder: ./single_play-sh -c=disablesingle -v=foldername_in_audiofolders
#
# TODO: When to call this script?
# Call this script with "playlistaddplay" (playout_controls.sh) everytime
#############################################################
# $DEBUG true|false
DEBUG=false

# Set the date and time of now
NOW=`date +%Y-%m-%d.%H:%M:%S`

for i in "$@"
do
case $i in
    -c=*|--command=*)
    COMMAND="${i#*=}"
    ;;
    -v=*|--value=*)
    VALUE="${i#*=}"
    ;;
    -d=*|--dir=*)
    FOLDER="${i#*=}"
    ;;
esac
done

PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# path to audio folders
AUDIOFOLDERSPATH=`cat $PATHDATA/../settings/Audio_Folders_Path`

if [ "$DEBUG" == "true" ]; then echo "## SCRIPT shuffle_play.sh ($NOW) ##" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR AUDIOFOLDERSPATH: $AUDIOFOLDERSPATH" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR COMMAND: $COMMAND" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR VALUE: $VALUE" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR FOLDER: $FOLDER" >> $PATHDATA/../logs/debug.log; fi

# Get folder name of currently played audio by extracting the playlist name
# ONLY if none was passed on. The "pass on" is needed to save position
# when starting a new playlist while an old is playing. In this case
# mpc lsplaylists will get confused because it has more than one.
# check if $FOLDER is empty / unset
if [ -z "$FOLDER" ]
then
    FOLDER=$(mpc lsplaylists)
    # actually, this should be the latest folder:
    FOLDER=`cat $PATHDATA/../settings/Latest_Folder_Played`
fi

# Some error checking: if folder.conf does not exist, create default
if [ ! -e "$AUDIOFOLDERSPATH/$FOLDER/folder.conf" ]
then
    # now we create a default folder.conf file by calling this script
    # with the command param createDefaultFolderConf
    # (see script for details)
    # the $FOLDER would not need to be passed on, because it is already set in this script
    # see inc.writeFolderConfig.sh for details
    if [ "$DEBUG" == "true" ]; then echo "  - calling inc.writeFolderConfig.sh -c=createDefaultFolderConf -d=\$FOLDER" >> $PATHDATA/../logs/debug.log; fi
    . $PATHDATA/inc.writeFolderConfig.sh -c=createDefaultFolderConf -d="$FOLDER"
    if [ "$DEBUG" == "true" ]; then echo "  - back from inc.writeFolderConfig.sh" >> $PATHDATA/../logs/debug.log; fi
fi
# Read the current config file (include will execute == read)
. "$AUDIOFOLDERSPATH/$FOLDER/folder.conf"
if [ "$DEBUG" == "true" ]; then echo "  content of $AUDIOFOLDERSPATH/$FOLDER/folder.conf" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then cat "$AUDIOFOLDERSPATH/$FOLDER/folder.conf" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR CURRENTFILENAME: $CURRENTFILENAME" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR ELAPSED: $ELAPSED" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR PLAYSTATUS: $PLAYSTATUS" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR RESUME: $RESUME" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR SHUFFLE: $SHUFFLE" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR LOOP: $LOOP" >> $PATHDATA/../logs/debug.log; fi
if [ "$DEBUG" == "true" ]; then echo "VAR SINGLE: $SINGLE" >> $PATHDATA/../logs/debug.log; fi

if [ "$DEBUG" == "true" ]; then echo "  Now doing what COMMAND wants: $COMMAND" >> $PATHDATA/../logs/debug.log; fi

case "$COMMAND" in


single_check)
        #Check if SHUFFLE is switched on. As this is called for each playlist change, it will overwrite temporary shuffle mode
        if [ $SINGLE == "ON" ]
        then
            if [ "$DEBUG" == "true" ]; then echo "  entering: single_check with value $SINGLE" >> $PATHDATA/../logs/debug.log; fi
            mpc single on
        else
            if [ "$DEBUG" == "true" ]; then echo "  entering: single_check with value $SINGLE" >> $PATHDATA/../logs/debug.log; fi
            mpc single off
        fi
    ;;
singleenable)
        if [ "$DEBUG" == "true" ]; then echo "  entering: singleenable" >> $PATHDATA/../logs/debug.log; fi
        # set the vars we need to change
        SINGLE="ON"
        # now calling a script which will only replace these new vars in folder.conf
        # (see script for details)
        . $PATHDATA/inc.writeFolderConfig.sh
    ;;
singledisable)
        if [ "$DEBUG" == "true" ]; then echo "  entering: singledisable" >> $PATHDATA/../logs/debug.log; fi
        # set the vars we need to change
        SINGLE="OFF"
        # now calling a script which will only replace these new vars in folder.conf
        # (see script for details)
        . $PATHDATA/inc.writeFolderConfig.sh
    ;;


*)
    echo "Command unknown"
    ;;
esac
