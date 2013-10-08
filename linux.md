# Linux and *nix like console scrapbook

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
