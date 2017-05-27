# Raspberry PI CIFS mount on boot

In order to mount NAS unit / network folder in linux / Raspbery PI
place this in your `/etc/fstab`

```bash
//192.168.1.150/Volume_1/  /mnt/mymount       cifs   uid=1000,gid=1000,rw,username=myusername,password=MyPAssWD      0       0
```

Now in order for Rasp PI to mount this on boot you need
to configure in `sudo raspi-config`


```bash
Boot Options > Wait for Network at Boot > Yes 
```

#### source

* [https://askubuntu.com/questions/157128/proper-fstab-entry-to-mount-a-samba-share-on-boot](https://askubuntu.com/questions/157128/proper-fstab-entry-to-mount-a-samba-share-on-boot)
