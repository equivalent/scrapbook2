# Linux and *nix like console scrapbook

old stuff can be found on 

* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/fedora_lxde
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/linux-unix
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/ubuntu_linux
* https://github.com/equivalent/scrapbook/blob/master/wisdom_inside/scraps/mint-mate

## limit throttle  bandwith 

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
