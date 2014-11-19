# Linux and *nix like console scrapbook

old stuff can be found on 

* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/fedora_lxde
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/linux-unix
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/ubuntu_linux
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/mint-mate


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

```
curl -s checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//' 
```

source: http://askubuntu.com/questions/95910/command-for-determining-my-public-ip

## mount smb folder 

... or how to mount NAS folder as local linux folder

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
sudo wondershaper eth1 500 100
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

## Extract tar.gz compresed file

```bash
tar -zxvf backup.tar.gz

#extract to folder
tar -zxvf /tmp/nginx-1.4.4.tar.gz.1 -C /tmp

```

## compress folder to tar.gz 

```bash
tar -zcvf prog-1-jan-2005.tar.gz /home/jerry/prog
```

## disk usage and what's the size of directory

```bash
du -sh ./my_folder  # overal directory size
df -h               # whole system size & space left

du -h --max-depth=1 # what is dir is taking most spoce
```

keywords: space left on linux machine

## free disk space on server (vm)

To delete downloaded packages (.deb) already installed (and no longer needed)

`sudo apt-get clean`

To remove all stored archives in your cache for packages that can not be downloaded anymore (thus packages that are no longer in the repository or that have a newer version in the repository).

`sudo apt-get autoclean`

To remove unnecessary packages (After uninstalling an app there could be packages you don't need anymore)

`sudo apt-get autoremove`


source: http://askubuntu.com/questions/5980/how-do-i-free-up-disk-space

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
