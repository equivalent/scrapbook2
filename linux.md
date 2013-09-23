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
