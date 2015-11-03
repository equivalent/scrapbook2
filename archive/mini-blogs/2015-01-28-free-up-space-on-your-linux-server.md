# Free up space on your Linux server

You can check your disk space usage with `df`, or particular folder `df -sh`.

You can check inode space usage by `df -i` (if you running caching server with file storage this will be often an issue)


### Delete downloaded packages (.deb) 

E.g.: already installed (and no longer needed)

```sh
sudo apt-get clean
```

### Remove stored archives in your cache 

E.g.:  packages that can not be downloaded anymore, packages are no longer in the repository or that have a newer version in the repository

```sh
sudo apt-get autoclean
```

### Remove packages after uninstalling an application

```sh
sudo apt-get autoremove
```

### Remove old unused kernels

list all your kernels (installed and deinstalled) :

```sh
dpkg --get-selections | grep linux-image
```

your currently used kernel

```
uname -r
```

to remove  particular kernel:

```sh
sudo apt-get remove --purge linux-image-X.X.XX-XX-generic
```

You can also run this script that will remove all unecesarry kernels, Be really carefull with this !!

```
#!/bin/sh
dpkg -l linux-*  | \
awk '/^ii/{ print $2}' | \
grep -v -e `uname -r | cut -f1,2 -d"-"` | \
grep  -e '[0-9]' | xargs sudo apt-get -y purge
```
* `dpkg -l linux-*` list all kernels 
* `uname -r` will tell you current kernel

# when stuff goes wrong

## clean up /boot partition

when you install kernel and you get error similar to this one: 

```
update-initramfs: Generating /boot/initrd.img-3.13.0-62-generic

gzip: stdout: No space left on device
E: mkinitramfs failure cpio 141 gzip 1
update-initramfs: failed for /boot/initrd.img-3.13.0-62-generic with 1.
run-parts: /etc/kernel/postinst.d/initramfs-tools exited with return
code 1
dpkg: error processing package linux-image-extra-3.13.0-62-generic
(--configure):
 subprocess installed post-installation script returned error exit
status 1
No apport report written because MaxReports has already been reached
                                                                    Processing
triggers for initramfs-tools (0.103ubuntu4.2) ...
update-initramfs: Generating /boot/initrd.img-3.13.0-62-generic



gzip: stdout: No space left on device
```

it may be you run out of space on boot partition

```
df /boot      # 100%
ls /boot
```

```
-rw-r--r--  1 root root  1169023 May 26 20:18 abi-3.13.0-54-generic
-rw-r--r--  1 root root  1169023 Jun 18 01:14 abi-3.13.0-55-generic
-rw-r--r--  1 root root  1169201 Jun 19 10:30 abi-3.13.0-57-generic
-rw-r--r--  1 root root  1169346 Jul  8 04:00 abi-3.13.0-58-generic
-rw-r--r--  1 root root  1169346 Jul 24 23:11 abi-3.13.0-59-generic
-rw-r--r--  1 root root  1169346 Jul 29 12:40 abi-3.13.0-61-generic
-rw-r--r--  1 root root  1169478 Aug 11 15:51 abi-3.13.0-62-generic
-rw-r--r--  1 root root  1169421 Aug 14 22:58 abi-3.13.0-63-generic
-rw-r--r--  1 root root   169832 May 26 20:18 config-3.13.0-54-generic
-rw-r--r--  1 root root   169832 Jun 18 01:14 config-3.13.0-55-generic
-rw-r--r--  1 root root   169832 Jun 19 10:30 config-3.13.0-57-generic
-rw-r--r--  1 root root   169832 Jul  8 04:00 config-3.13.0-58-generic
-rw-r--r--  1 root root   169832 Jul 24 23:11 config-3.13.0-59-generic
-rw-r--r--  1 root root   169833 Jul 29 12:40 config-3.13.0-61-generic
-rw-r--r--  1 root root   169833 Aug 11 15:51 config-3.13.0-62-generic
-rw-r--r--  1 root root   169833 Aug 14 22:58 config-3.13.0-63-generic
```

Remove the old kernels like this:

```
sudo dpkg --purge linux-image-3.13.0-53-generic
sudo dpkg --purge linux-image-3.13.0-54-generic
# ...
sudo apt-get -f install # tell to continue installing the latest kernel
sudo apt-get autoremove
```

# source of information

* http://askubuntu.com/questions/138026/how-do-i-delete-kernels-from-a-server
* http://askubuntu.com/questions/5980/how-do-i-free-up-disk-space
* http://ubuntuforums.org/showthread.php?t=2291788
