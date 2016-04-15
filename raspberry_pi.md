
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
