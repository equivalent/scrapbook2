# Free up space on your Linux server


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
