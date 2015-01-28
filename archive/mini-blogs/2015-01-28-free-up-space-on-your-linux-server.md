# Free up space on your Linux server

### Delete downloaded packages (.deb) already installed (and no longer needed)

```sh
sudo apt-get clean
```

### Remove stored archives in your cache for packages that can not be downloaded anymore

E.g.: packages are no longer in the repository or that have a newer version in the repository

```sh
sudo apt-get autoclean
```

### Remove unnecessary packages (After uninstalling an app)

```sh
sudo apt-get autoremove
```

### Remove old unused kernels

Be really carefull with this 

```
#!/bin/sh
dpkg -l linux-*  | \
awk '/^ii/{ print $2}' | \
grep -v -e `uname -r | cut -f1,2 -d"-"` | \
grep  -e '[0-9]' | xargs sudo apt-get -y purge
```
* `dpkg -l linux-*` list all kernels 
* `uname -r` will tell you current kernel

source: http://askubuntu.com/questions/138026/how-do-i-delete-kernels-from-a-server
