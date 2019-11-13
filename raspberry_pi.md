

# raspbery PI photoframe

> this is unfinished article for blog.eq8.eu. It's not completed but still many usefull information


Install `feh`

`sudo apt install feh`
`sudo apt install xscreensaver`


### photoframe after boot (autostart)

create file in `/home/pi/.config/lxsession/LXDE-pi/autostart`

with this content:

```bash
@lxpanel --profile LXDE
@pcmanfm --desktop --profile LXDE
@xset s off
@xset -dpms
@xset s noblank
@feh -Y -x -q -D 120 -B black -F -Z -z -r /home/pi/Pictures/
```


### photo frame - just a script (manual)


```bash
#!/bin/bash
xset s off
xset -dpms
xset s noblank
feh -Y -x -q -D 120 -B black -F -Z -z -r /home/pi/Pictures/
```

created : 2019-11-13

#  raspbery PI motion camera

> this is unfinished article for blog.eq8.eu. It's not completed but still many usefull information


You will just need RaspberiPI (or any computer / laptop) and Webcam  and
power source.

> so CCTV like setup

I'll assume you use Linux as your operating system (no windows in this
article, sorry) and we will use program `motion` @todo


```ruby
sudo vim /etc/motion/motion.conf

target_dir
framerate
process_id_file
logfile
daemon on

```

```
motion
#  .... Logging to file /home/pi/.motion/motion.log
```


https://www.raspberrypi.org/documentation/remote-access/ssh/




```
crontab -e
@reboot motion
```




crap

```
if pgrep -x "motion" > /dev/null
then
    echo "Running"
else
    echo "Stopped"
    motion
fi
```



https://gist.github.com/equivalent/27792e89df56e15cd0bb3db400893ee8



# rasberian camera

to enaxle camera `sudo raspi-conig` and enable camera. Finish & reboot


* https://www.raspberrypi.org/documentation/usage/camera/README.md
* https://www.raspberrypi.org/documentation/usage/camera/raspicam/raspistill.md

# resizing Ubuntu Mate 


step 1.:

```
    root@auser-desktop:~# sudo fdisk /dev/mmcblk0

    Welcome to fdisk (util-linux 2.25.2).
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.


    Command (m for help): p
    Disk /dev/mmcblk0: 14,9 GiB, 15931539456 bytes, 31116288 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x00000000

    Device         Boot  Start      End  Sectors  Size Id Type
    /dev/mmcblk0p1 *      2048   133119   131072   64M  c W95 FAT32
(LBA)
    /dev/mmcblk0p2      133120 31116287 30983168 14,8G 83 Linux

    Command (m for help): d       
    Partition number (1,2, default 2): 2

    Partition 2 has been deleted.

    Command (m for help): n
    Partition type
       p   primary (1 primary, 0 extended, 3 free)
       e   extended (container for logical partitions)
    Select (default p): p
    Partition number (2-4, default 2): 2
    First sector (133120-31116287, default 133120):
    Last sector, +sectors or +size{K,M,G,T,P} (133120-31116287, default
31116287):

    Created a new partition 2 of type 'Linux' and of size 14,8 GiB.

    Command (m for help): w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Re-reading the partition table failed.: Device or resource busy

    The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8).

    root@auser-desktop:~#
```


step 2.: now reboot


step 3.: 

```
    auser@auser-desktop:~$ sudo resize2fs /dev/mmcblk0p2
    [sudo] password for auser:
    resize2fs 1.42.12 (29-Aug-2014)
    The filesystem is already 3872896 (4k) blocks long.  Nothing to do!

    auser@auser-desktop:~$
```

https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=110785
