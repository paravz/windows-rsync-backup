#!/bin/bash
#
# Script uses rsync to backup local Windows drives to specified media (network
# share or any locally mounted drive)
# Requires Cygwin (with rsync) to be installed.
#
# Requires backup destination profie to be defined and "-n" dry run option
# commented out to work
# 
# More details in https://github.com/paravz/windows-rsync-backup

[ -z $1 ] && echo usage: $0 BackupProfileName && exit 1
BPROFILE=$1

BDEST="undefined"
needunmount=0

# Define your backup destinations below. Specify the drive letter backup disk
# (ie USB) or network share details
case "$BPROFILE" in
    "netshare" )
        echo "== Using Home Samba/Network profile"
        BDEST="/cygdrive/y"
        echo "== Mount network share to use as backup destination: $BDEST"
        if [ ! -d $BDEST/D ]; then
            # looks ugly as all backslashes needs to be escaped (doubled) in bash
            net use y: \\\\srv-lh\\f\$\\laptop || { net use y: \\\\srv-lh\\f\$\\laptop /user:administrator || { echo "ERROR: network share mount failed, aborting"; exit 1;}; }
            needunmount=1
        fi

    ;;
    "usb" )
        # You can use an encrypted or non-encrypted USB backup drive, defined
        # by a drive letter in Windows You can mount encrypted drive before
        # running this backup script, or mount it right here in the profile.
        
        # TrueCrypt example to mount encrypted partition to letter g:
        #/cygdrive/c/Program\ Files/TrueCrypt/TrueCrypt.exe /a /v "\Device\Harddisk3\Partition1" /l "g:" /e
        echo "== Using external USB drive profile"
        BDEST="/cygdrive/g/laptop"
        echo "== Using backup destination: $BDEST"
        if [ ! -d $BDEST/D ]; then
            echo "ERROR: destination drive not found, aborting"
            exit 1
        fi
        # optional per profile addition to RSYNCOP, EXCLOP
        #RSYNCOP="$RSYNCOP -n"
        #RSYNCCMD="echo $RSYNCCMD"
        
    ;;
    * )
        echo "== Unknown profile: $bprofile, aborting"
        exit 1
    ;;
esac

# rsync command. time is used to measure how long rsync is running
RSYNCCMD="time rsync"
# echo instead of rsync, uncomment for testing and validating
#RSYNCCMD="echo $RSYNCCMD"

# Primary rsync parameters: -a (preserving permissions, more secure) vs -rltD (permissions not preserved)
# How to choose:
# * -a keeps source-machine specific windows permissions in backup (unique UID), which might 
# make accessing backup from another windows machine troublesome, since System and Administrators
# UIDs on 2 different windows copmputers will be different.
# * -rltD doesn't keep permissions, you won't be able to properly restore Windows system files with this option.
# It's perfect for "content" backup, ie  photos, music, documents. You can
# access USB drive with such backup from any other Windows machine

#RSYNCOP="-aHh"
RSYNCOP="-rltDHh"

# Optional rsync parameters
# * --delete produces exact copy of src on destionation, files not present in src on time of backup 
# will be deleted from destionation. Files you backed up previously, but sice deleted, will be 
# deleted in backup with --delete.
# If you have enough disk space on destionation don't use --delete until you run out of space.
# Even then you can use --delete once to cleanup old files and disable it again

#RSYNCOP="$RSYNCOP --delete"

# * -n: "dry run" mode for testing. -n simulates rsync execution without
# copying or deleting anything

RSYNCOP="$RSYNCOP -n"

#global rsync exclusions, applied to all drives and all backup profiles
#EXCLOP='--exclude \*Windows/\* --exclude pagefile.sys --exclude \*RECYCLE.BIN\* --exclude "*System Volume Information*" --exclude "*Lightroom 5 Catalog Previews.lrdata*" --exclude \*VMs/\*'
EXCLOP='--exclude /Windows/ --exclude pagefile.sys --exclude \*RECYCLE.BIN\* --exclude "System Volume Information" --exclude "Lightroom 5 Catalog Previews.lrdata" --exclude /VMs/'

# A scheduled Windows backup can be optionally triggered via command line.
# This is helpful if your schedule saves backup on one of the drives on the
# local PC, allowing rsync to offload windows backup externally

#cd C:\Windows\System32
#rundll32.exe /d sdengin2.dll,ExecuteScheduledBackup

echo
if [ -d ${BDEST}/C ]; then
    echo "== Start rsync full C:\ "
    # per disk exclusion
    excloplocal=$EXCLOP''
    date
    # eval is a necessary hack, there might be a cleaner way
    echo "== Running cmd:"
    echo "$RSYNCCMD $RSYNCOP /cygdrive/c/ ${BDEST}/C $excloplocal"
    eval "$RSYNCCMD $RSYNCOP /cygdrive/c/ ${BDEST}/C $excloplocal"
else
    echo "== Disk C destination folder not found, skipping sync"
fi

echo
if [ -d ${BDEST}/D ]; then
    echo "== Start rsync full D:\ "
    # per disk exclusion
    excloplocal=$EXCLOP' --exclude Program\ Files'
    date
    echo "== Running cmd:"
    echo "$RSYNCCMD $RSYNCOP /cygdrive/d/ ${BDEST}/D $excloplocal"
    eval "$RSYNCCMD $RSYNCOP /cygdrive/d/ ${BDEST}/D $excloplocal"
else
    echo "== Disk D destination folder not found, skipping sync"
fi

echo
if [ -d ${BDEST}/E ]; then
    echo "== Start rsync full E:\ "
    # per disk exclusion
    excloplocal=$EXCLOP' --exclude tmp_New_Folder'
    date
    echo "== Running cmd:"
    echo "$RSYNCCMD $RSYNCOP /cygdrive/e/ ${BDEST}/E $excloplocal"
    eval "$RSYNCCMD $RSYNCOP /cygdrive/e/ ${BDEST}/E $excloplocal"
else
    echo "== Disk E destination folder not found, skipping sync"
fi

vmlist=""
# get list of running VMs to suspend and backup
# for Parallels Workstation for Windows, should be the same for Parallels Desktop for Mac
prlctl.exe list >/dev/null 2>&1 && vmlist=`prlctl.exe  list -aH|grep running|awk '{print $1}'`

echo
if [ "A${vmlist}A" != "AA" ]; then
    echo "== Suspend currently running VMs ($vmlist)"
    for vm in $vmlist; do prlctl suspend $vm; done
fi

echo
if [ -d /d/VMs ]; then
    echo "== Start rsync D:\VMs "
    date
    echo "== Running cmd:"
    echo "$RSYNCCMD $RSYNCOP /cygdrive/d/VMs ${BDEST}/D"
    eval "$RSYNCCMD $RSYNCOP /cygdrive/d/VMs ${BDEST}/D"
else
    echo "== D:\VMs destination folder not found, skipping sync"
fi

echo
if [ -d /e/VMs ]; then
    echo "== Start rsync E:\VMs "
    date
    echo "== Running cmd:"
    echo "$RSYNCCMD $RSYNCOP /cygdrive/e/VMs ${BDEST}/E"
    eval "$RSYNCCMD $RSYNCOP /cygdrive/e/VMs ${BDEST}/E"
else
    echo "== E:\VMs destination folder not found, skipping sync"
fi

if [ "A${vmlist}A" != "AA" ]; then
    echo "== Resuming VMs that were running ($vmlist)"
    for vm in $vmlist; do prlctl resume $vm; done
fi

# Example for external media with additional check for mounted device, as you
# don't want to overwrite backups of different devices connected to the same
# drive letter by Windows.
# Check if blackberry is connected via USB, backup SD card
echo
if [ -d /cygdrive/e/BlackBerry -a -d ${BDEST}/abb ]; then
    echo "== Start rsync blackberry h:\ to network"
    date
    echo $RSYNCCMD $RSYNCOP /cygdrive/h/ ${BDEST}/abb
else
    echo "== Blackberry sync skipped"
fi

LOGFILE=${BDEST}/backuplog.txt
date >> "${LOGFILE}"
unix2dos "${LOGFILE}" >/dev/null 2>&1
echo "Done"
date

if [ $needunmount -eq 1 ]; then
    echo "== Unmounting backup network drive"
    sleep 5
    # /yes forces unmount, even if there are open files/directories
    net use y: /delete /yes
fi
