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


# source of information

* http://askubuntu.com/questions/138026/how-do-i-delete-kernels-from-a-server
* http://askubuntu.com/questions/5980/how-do-i-free-up-disk-space
