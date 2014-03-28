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

## Notes
1. See comments in the script for an encrypted TrueCrypt drive mount example
2. Common rsync options are explained in script comments, defaults should suite most use cases (after removal of -n)
3. Script contains my default "Windows" exclusions for rsync. You can add more exclusions easily per backup profile and per source drive letter using provided examples
4. There is special case of handing running Parallels Virtual Machines if you have any, they are suspended before rsync and resumed after. Same approach can be used for VirtualBox, VMware, etc. 



## License
The MIT License (MIT)

Copyright (c) 2014 Alec Istomin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
