Rsync backup script for Windows
====================

## How to use

1. Download and install [Cygwin](http://cygwin.com/), make sure to install rsync

2. Download [rsync_backup_win.sh](https://raw.githubusercontent.com/paravz/windows-rsync-backup/master/rsync_backup_win.sh) via browser or from Cygwin shell:

`$ wget https://raw.githubusercontent.com/paravz/windows-rsync-backup/master/rsync_backup_win.sh`

3. Connect a large enough USB drive and create a backup destination folder there, ie G:\laptop

`$ mkdir -p /cygdrive/g/laptop`

4. For every Windows Drive letter you want to backup, create a corresponding folder, using capital letters, ie: G:\laptop\C, G:\laptop\D

`$ mkdir -p /cygdrive/g/laptop/{C,D}`

5. Edit rsync_backup_win.sh to define your USB backup destination:
`BDEST="/cygdrive/g/laptop"`

6. Run the backup from Cygwin:

`$ ~/rsync_backup_win usb`

Script defaults include `rsync -n`, "dry run" option to test everything first. Comment it out: `#RSYNCOP="$RSYNCOP -n"` for actual rsync execution 
