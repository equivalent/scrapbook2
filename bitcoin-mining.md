# cgminer on Ubuntu with ASICminer


    # step 1
    apt-get install autoconf gcc make git libcurl4-openssl-dev libncurses5-dev libtool libjansson-dev libudev-dev libusb-1.0-0-dev

    # step 2
    cd /usr/src/
    git clone https://github.com/ckolivas/cgminer.git
 
    # step 3
    cd cgminer
    ./autogen.sh --enable-icarus

    # step 4
    make

    # step 5
    # Plug your ASICMiner Block Erupter USB’s into the USB ports of your device.

    # step 6
    ./cgminer -o http://your.pool.com:8332 -u username_worker -p yourpassword


source http://blog.phrog.org/2013/07/06/simple-debian-cgminer-asicminer-block-erupter-usb-setup/
