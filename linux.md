# Linux and *nix like console scrapbook

old stuff can be found on 

* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/fedora_lxde
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/linux-unix
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/ubuntu_linux
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/mint-mate

# run command in background /daemon like

```
nohup command &
```


## Espeaker

```bash
espeak -s 250
```

## change hostname on server

```
sudo vim /etc/hostname
sudo vim /etc/hosts
sudo service hostname restart
```

* http://askubuntu.com/questions/9540/how-do-i-change-the-computer-name


## what services / ports the server is using

```
sudo netstat -tulpn
```

## convert mp4 to flv

`ffmpeg -i source.mp4 -c:v libx264 -ar 22050 -crf 28 destinationfile.flv`

* http://stackoverflow.com/questions/8504923/how-to-convert-mp4-video-file-into-flv-format-using-ffmpeg


## join images to video (animation)

**ffmpeg ubuntu  installation with libx264**

(mkv) othervise default mp4 videos are crap !

```
cd /my/path/where/i/keep/compiled/stuff
git clone http://source.ffmpeg.org/git/ffmpeg.git
cd ffmpeg
./configure --enable-gpl --enable-libx264
make
make install
ldconfig
```

* https://trac.ffmpeg.org/wiki/How%20to%20quickly%20compile%20FFmpeg%20with%20libx264%20(x264,%20H.264)

**how to convert**

```
# images must be in order like this:
# a1.jpg
# a2.jpg
# ...
# a709.jpg
# ..
ffmpeg -y -i "a%d.jpg" /tmp/output.m4v

# for framerate use `-r 30` option (30 is fps)

# or for lumion out Photo000001.jpg format
ffmpeg -y -i "Photo%06d.jpg" /tmp/output.m4v
```

* http://superuser.com/questions/19899/mac-os-x-easiest-free-non-quicktime-pro-application-for-converting-numbered

## samba 

source: http://askubuntu.com/questions/208013/how-can-i-set-up-samba-shares-to-only-be-accessed-by-certain-users

1. Make sure that every user can access the common media folder on the unix side (without samba)
2. Make sure each user has a samba password set. You can set it with
   `sudo smbpasswd -a your_user`
3. Look at /etc/samba/smb.conf: check if the line `security = user` is set
   in the `[GLOBAL]` section
4. Set your shares in /etc/samba/smb.conf,  example:

    ```
    #  This will be accessible via `\\yourserver\allaccess`
    [allaccess]
        path = /media/common
        read only = no
        writeable = yes
        browseable = yes
        valid users = one, two, three, four
        create mask = 0644
        directory mask = 0755 # if you set this, all files get written as this user
        force user = one

    [special]
        path = /home/two/onlytwo
        read only = no
        writeable = yes
        browseable = yes
        valid users = one
        create mask = 0640
        directory mask = 0750
    ```

5. `sudo service smbd restart`





## colorize output file

```

tput setaf 9; echo  'test text'

tput setab 7; tput setaf 9; echo  'test text with bg'

# given in ~/doge.txt you have image of doge
tput setab 7; tput setaf 9; printf  '%b\n' $(cat /home/my-user/doge.txt)
```

## kill all ssh sessions

if someone is ssh'd to your computer 

```
who # list of all conected ppl ...the ip adresess are ssh connections
ps -ef | grep sshd | grep -v root | grep -v 12345 | grep -v grep | awk '{print "sudo kill -9", $2}' |sh 

who
```

## turn on off touchpat

```
synclient TouchpadOff=1
synclient TouchpadOff=0
```

toggle

```
if synclient -l | egrep "TouchpadOff.*= *0" ; then 
    synclient touchpadoff=1 ; 
else 
    synclient touchpadoff=0 ; 
fi
```

I recommend to put this to a sh script (e.g.: `~/.hp_5330_misc/touchpadoff.sh`) and set ubuntu keyboard shortcut to trigger this script

source 

* http://askubuntu.com/questions/65951/how-to-disable-the-touchpad/67724
* http://unix.stackexchange.com/questions/50440/how-to-create-script-that-toggles-one-value-in-synclient


## Kensington orbit 2 button scrooll ball scroling in linux / ubuntu 15.10


add this to `/usr/share/X11/xorg.conf.d/10-evdev.conf `

```

# ...
Section "InputClass"
        Identifier "Kensington     Kensington USB/PS2 Orbit"
        Driver "evdev"
        MatchProduct "Kensington"
        MatchDevicePath "/dev/input/event*"
        MatchIsPointer "yes"
        Option "ButtonMapping" "1 2 3 4 5 6 7 8"
        Option "EmulateWheel" "true"
        Option "EmulateWheelButton" "3"
        Option "EmulateWheelTimeout" "200"
        Option "ZAxisMapping" "4 5"
        Option "XAxisMapping" "6 7"
        Option "Emulate3Buttons" "true"
        Option "Emulate3Timeout" "50"
EndSection
```

it's from a discussion I cannot find as I restarted my X server (btw you
need ot restart Xorg in order to this to work)  therefore I have no
source link. but the author was mentioning than the middle button is not
working but scrolling is

## install Ubuntu 15.10 on Dell 2915 XPS


replace wifi card for intell otherwise all should be good

http://hgdev.co/install-ubuntu-15-10-on-the-dell-xps-13-9343-2015-a-complete-guide/
http://hgdev.co/optimize-battery-life-on-ubuntu/

palm detection :

```
# to unable palm detection
synclient PalmDetect=1
```

or :


```
sudo vim /usr/share/X11/xorg.conf.d/10-evdev.conf
```


```
Section "InputClass"
  Identifier "evdev touchscreen catchall"
  MatchIsTouchscreen "on"
  MatchDevicePath "/dev/input/event*"
  Driver "evdev"
  Option "Ignore" "on"
EndSection
```

## encrypt folder 

```sh
sudo apt-get install encfs

encfs /home/user/Documents/encrypted_folder/ /home/user/mount_point
fusermount -u /home/user/mount_point  # unmount
```

notes: 
* encrypted_folder and mount_point needs to be empty when init encrypt
* make sure you have read write permissions




## ssh with specific pem file

```
ssh -i ~/Downloads/my-key.pem ubuntu@52.333.222.123
```

## change lid closed settings LXDE ubuntu

http://ubuntuhandbook.org/index.php/2014/04/enable-hibernate-ubuntu-14-04/

```
sudo vim /etc/systemd/logind.conf
```

```
#HandleLidSwitch=suspend
```

```
sudo restart systemd-logind
```

## image magic trikcs

resize one image

```
convert my-img.jpg -resize 900x90
```

resize bulk / batch of images

```
mogrify  -resize 900x900 *.jpg
```

bulk of images to pdf

```
convert *jpg -compress jpeg test.pdf
```

## badblocks (check hdd disk for bad sectors / blocks)

note badblocks seems to me destructive program, rather never use it on HDD of wich data you need

more info https://wiki.archlinux.org/index.php/badblocks#Testing_for_Bad_Sectors

```sh
 badblocks -nsv /dev/sdb     # run read-write Test (non-destructive) ...but read more 
                             # about destructivity in that link above (will overide and return data)
 ```

## store ssh private key in differnt dir

e.g. You can have multiple ssh_keys on one comuputer, you may want to store one of you keys in separate  encrypted container (e.g. work comupter, store personal in Truecrypt while leave work one in Home dir)

```
vim ~/.ssh/config

IdentityFile ~/my_mount_for_crypted_dir/personal_private key
```

http://stackoverflow.com/questions/84096/setting-the-default-ssh-key-location

## ubuntu 14 change number of workspaces

current number of worspaces

```
dconf read /org/compiz/profiles/unity/plugins/core/hsize
dconf read /org/compiz/profiles/unity/plugins/core/vsize
```

set new number 

```
dconf write /org/compiz/profiles/unity/plugins/core/hsize 2
```

source:

http://askubuntu.com/questions/447673/how-to-change-number-of-workspaces-from-command-line
http://askubuntu.com/questions/459284/how-to-use-different-workspaces-on-ubuntu-14-04

## what is my public IP address (global ip address dns)

keywords: myip my ip my-ip 

```
curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//' 

# same thing in var
myip=$(curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
echo $myip



 ## depricated: 
 #myip=$(dig +short myip.opendns.com @resolver1.opendns.com)
```

source: http://askubuntu.com/questions/95910/command-for-determining-my-public-ip


## mount smb folder in /etc/mtab

```bash
//192.168.1.66/MyVolume/  /mnt/my_drive       cifs   uid=1000,gid=1000,rw,username=enrike,password=iglasias      0       0


# old
# //192.168.1.66/MyVolume/  /mnt/my_drive       cifs   uid=1000,gid=1000,rw,username=enrike,password=iglasias,nobootwait      0       0
```

## mount smb folder 

... or how to mount NAS folder as local linux folder

> ubuntu 16.04 you need to `sudo apt-get install cifs-utils`

```bash
mkdir /mnt/my_nas_drive
mount -t cifs //ntserver/download -o username=vivek,password=myPassword /mnt/my_nas_drive
# you can skip -o option on public
```
http://www.cyberciti.biz/tips/how-to-mount-remote-windows-partition-windows-share-under-linux.html




## secure delete

```
sudo apt-get install secure-delete


srm # - securely delete an existing file
smem # - securely delete traces of a file from ram
sfill # - wipe all the space marked as empty on your hard drive
sswap # - wipe all the data from you swap space.

```

source: http://superuser.com/questions/19326/how-to-wipe-free-disk-space-in-linux

## How much is memory RAM beeing used

```bash
free -m
```

##  Free Inode Usage

if you run out of space on Linux (Ubuntu) server machine, you may still have enough space with
`df -h` but your inodes are taken

```
# show inode usage overal in system
df -i 

# show what folders are consuming most inod in current folder
sudo find . -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n
```

delete stuff in those folders (simple `rm -rf`) ...just be carefull what you delete

source: 

* http://stackoverflow.com/questions/653096/howto-free-inode-usage
* collegue Sean (thx dude)

## timestamp linux

... or how to output time in bash
... or how to output date in bash
... or how to name file with date

```bash
echo "foo_$(date +%Y-%m-%d_%s)_bar"
# foo_2014-07-07_1404729340_bar


mkdir "foo_$(date +%Y-%m-%d_%s)"

```

## restart audio in Ubuntu

...or restart soundcard

```bash
pulseaudio -k && sudo alsa force-reload
```

http://askubuntu.com/questions/230888/is-there-another-way-to-restart-the-sound-system-if-pulseaudio-alsa-dont-work


## curl

curl server headers (As seen in [NginX scrapbook](https://github.com/equivalent/scrapbook2/blob/master/nginx.md) )

```
curl -kvI https://my_application.com
```

curl Json POST on https:// (-k no igrore self signerd warning)


```
curl -i -k -H "Content-type: application/json" -H "Accept: application/json" -X POST  http://0.0.0.0:3000
```

token

```
curl localhost:3000/api/v1/status -H 'Authorization: Token token="key"'
```

post json from a file

```
curl -X POST -H 'Content-Type: application/json' -d @spec/fixtures/application.json localhost:3000/api/v1/applications
```

## tail remoote server log file

```sh
ssh -t user@212.95.123.123 'tail -f ~/apps/my_app/current/log/trial.log'
```



##  discover all IP adresses in local network

or ping ip range

```sh
nmap -sP 192.168.1.*
nmap -sP 192.168.1.0-255
```

## send html email via linux console


```sh
# sudo apt-get install mailutils  # if mail comm not worknig  ...also you need postfix 

echo "<h1>Hi</h1><p>test hello</p>" > /tmp/my_mail_content.html
mail  -a 'Content-Type: text/html' -s "some subject" myemail@test.com  < /tmp/my_mail_content.html
```


## remote desktop control

### LUbuntu

```sh
sudo apt-get install x11vnc vnc-java # install
x11vnc -storepasswd  # this will set up password
 x11vnc -forever -usepw -httpdir /usr/share/vnc-java/ -httpport 5800  # open server 
```

```
# add   x11vnc -forever -usepw -httpdir /usr/share/vnc-java/ -httpport 5800
sudo vim  /etc/xdg/lxsession/Lubuntu/autostart
```

http://linuxlubuntu.blogspot.co.uk/2011/02/setup-vnc-server-for-lubuntu.html

###  to connect  from OSx

lunch `safari` and `vnc://192.168.1.123`  (your IP )



## limit throttle  bandwith 

### limit one program

```
trickle -u (upload limit in KB/s) -d (download limit in KB/s) application
trickle -u 15 -d 2000 /usr/bin/google-chrome-stable --incognito %U

```

### limit entire bandwith

```
sudo apt-get wondershader
sudo wondershaper eth1 800 200
sudo wondershaper clear eth1 
```

http://jwalanta.blogspot.co.uk/2009/04/easy-bandwidth-shaping-in-linux.html

## open port 

```bash
su
iptables -I INPUT -p tcp --dport 666 --syn -j ACCEPT
iptables -F  # flush, this will reload the rules so that new changes are applyied 
```

... of course this wont work if you are not using iptables or external firewal

http://www.tixati.com/optimize/open-ports-linux.html

## Check what ports are opened on linux machine

```bash
nmap -sS -O 127.0.0.1

netstat -lntu
#    -l = only services which are listening on some port
#    -n = show port number, don't try to resolve the service name
#    -t = tcp ports
#    -u = udp ports
#    -p = name of the program

netstat -vatn
```

http://www.cyberciti.biz/faq/how-do-i-find-out-what-ports-are-listeningopen-on-my-linuxfreebsd-server/

## Where is application instaled

```bash
whereis nginx   
# nginx: /usr/sbin/nginx /etc/nginx /usr/share/nginx /usr/share/man/man1/nginx.1.gz
which nginx
# /usr/sbin/nginx
```

## convert video to gif

```
ffmpeg -i small.mp4 small.gif
```

https://davidwalsh.name/convert-video-gif

## Extract tar.gz compresed file

```bash
tar -zxvf backup.tar.gz

#extract to folder
tar -zxvf /tmp/nginx-1.4.4.tar.gz.1 -C /tmp

# tar only
tar -xvf /tmp/backup.tar -C /tmp

# gzip only 
gzip -d /tmp/backup.gz
```

## compress folder to tar.gz 

```bash
tar -zcvf prog-1-jan-2005.tar.gz /home/jerry/prog
```

## compress with 7zip

```
#  sudo apt install p7zip-full
7z a -p git.7z /path/to/git

# extract
7z x git.7z

``

## copmpress with aes password


encrypt

```
tar cz folder_to_encrypt | openssl enc -aes-256-cbc -e > out.tar.gz.enc
```

Decrypt

```
openssl aes-256-cbc -d -in out.tar.gz.enc | tar xz
```

Or using gpg

```
gpg --encrypt out.tar.gz
```

* http://superuser.com/questions/162624/how-to-password-protect-gzip-files-on-the-command-line


## disk usage and what's the size of directory

```bash
du -sh ./my_folder  # overal directory size
df -h               # whole system size & space left

du -h --max-depth=1 # what is dir is taking most spoce
```

keywords: space left on linux machine

## free disk space on server (vm)

delete downloaded packages, remove unnecesary kernels

Entire topic moved to miniblog here: https://github.com/equivalent/scrapbook2/blob/master/archive/mini-blogs/2015-01-28-free-up-space-on-your-linux-server.md

## solve VM out of space even after deleting large file

on Ubuntu server VM I had a problem tat log was over 2GB and the system throw
`No space left on device`error (and application 405 error). When I deleted the 
log file the system was still complaining that it's out of space. I had to restart
the VM and for future to prevent this do this: 

whatever your log directory is, empty it and then use a `ramisk` for that folder: eg

    mount -t tmpfs -o size=1024M tmpfs /var/log  
    # or  /home/deploy/apps/my_app/log/

## generate ssh public & private key

    ssh-keygen -t rsa -C "your_email@example.com"

## Replace string/text in multiple files in folder

    grep -rl 'I am a car' ./ | xargs sed -i 's/I am a car/I am a Plane/g'
    
    grep -rl 'windows' ./ | xargs sed -i 's/windows/linux/g'

## ls permissions 

    ls -ld

## lock screen on lxde

    xscreensaver-command -lock
      
## Motion (web-cam motion surveillance software)

    sudo apt-get install motion
    sudo chmod 755 /etc/motion/motion.conf
    vim /etc/motion/motion.conf
       #  change the target_dir  to /home/user/Dropbox/motion
    
    # to start run    
    motion


source: http://www.chriswpage.com/2009/05/setup-an-advanced-webcam-security-system-with-ubuntu-8-04-and-motion/
    

## ubuntu, lubuntu, mint set US as default layout

    setxkbmap -layout us

## CentOS send mail with attachement

    yum install mail

    mail -a /tmp/school_counts.csv -s 'blaa subject' "tomas@blaaa.com" < /dev/null

## Ubuntu, Mint set up postfix 

    sudo apt-get install postfix
    sudo apt-get install mailutils

    echo 'Teeeeest maaaaail' >  mail.txt
    mail -s "some subject" me@mydomain.com < mail.txt

    # if this wont work do
    sudo dpkg-reconfigure postfix


ubuntu 12.04 or mint 13
date: 2013-03-20
keys: postfix, sendmail , mail rubymail, linux, send email from command line


## Replace string in multiple file

    sed  -i 's/what/with_what/g' app/*/*.rb
    sed  -i 's/lambda/->/g' app/*/*.rb
    

## Changing (spoof) mac address

in Ubuntu

    sudo ifconfig wlan0 down
    sudo ifconfig wlan0 hw ether xx:xx:xx:xx:xx
    sudo ifconfig wlan0 up
 
in OsX

    sudo ifconfig en0 ether d4:33:a3:ed:f2:12
    
you can generate random with:

    openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'
    
remember, it depends on hardwar if it's possible to change mac adress
