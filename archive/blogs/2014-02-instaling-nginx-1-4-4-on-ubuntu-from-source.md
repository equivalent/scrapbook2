# Installing Nginx 1.4.4 from source on Ubuntu 12.04 (Precise)

first one good recommendation: 

### Install NginX from Ubuntu packages !

One thing to consider is to actually install NginX direcly from Ubuntu ppa

```bash
sudo add-apt-repository ppa:nginx/stable --yes
sudo apt-get -y update
sudo apt-get -y install nginx
```

The reason for this is that the nginx ppa keeps NginX up to date. During the time I was writing tutorial on how to install NginX 1.4.4 from source, Nginx 1.4.5 was released and was automatically upgraded (yes with SNI) on one other server I'm managing. 

So there is no real point (unless you want to do some ninja stuff with NginX) to compile it on Ubuntu.

http://wiki.nginx.org/Install#Ubuntu_PPA


## Installing from source 

First some system dependencies:

```bash
sudo apt-get install make    # doh !
```

We want to have the "rewrite" option in our Nginx (allows us to do redirect), so add dependancies for that.

```bash
sudo apt-get install libpcre3-dev libpcre++-dev
```

Btw if anyone was getting `error: pcre-config not found, install the pcre-devel package or build with --without-pcre`
during running `./configure`, installing dependencies above will solve this.

(of course OpenSSl is also dependancy but for Ubuntu 12.04 that's automatic)

Now lets get the source files

http://wiki.nginx.org/Install#Source_Releases

```bash
wget -P /tmp http://nginx.org/download/nginx-1.4.4.tar.gz  # fetch the release
tar -zxvf /tmp/nginx-1.4.4.tar.gz -C /tmp                  # extract it
cd /tmp/nginx-1.4.4                                        # go to folder
```

Compile & install Nginx

```bash
./configure  --prefix=/opt/nginx --sbin-path=/usr/sbin/nginx \
--conf-path=/opt/nginx/nginx.conf --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
--with-http_ssl_module 
```

option `with-http_ssl_module`  will enable SNI support (server name idenifier)
(allows you to have server certificates) if you don't need those you can skip this option

When I was googling how to enable this I run into dozens of CentOS blogs recommendnig to pass following

```
--with-openssl=/usr/bin/openssl --with-openssl-opt="enable-tlsext" 
```

...well this wont work  I guess that is for older versions of NginX. 

Also your OpenSSl lib should support SNI which native Ubuntu 12.04 OpenSSL 1.0.1 supports

Ok enough of SNI, finish compilation 


```
make
sudo make install
```

Now you should be able to do check the version and if SNI is on

```bash
nginx -V
# nginx version: nginx/1.4.4
# TLS SNI support enabled   # if you dont see this line, something went wrong, 
                            # and SNI will not work, check your OpenSSL 
```


### Recompiling

check article http://extralogical.net/articles/howto-compile-nginx-passenger.html there are some useful information.

Author is mentioning that when you do `nginx -V` you'll get virsion and list of all the options you passed
during `.configure`. So you don't have to write down options, just copy them from the output and pass to `.configure` again

### Init d

To be able to call NginX as service:

```bash
sudo service nginx start
sudo service nginx stop
```

...you need to have init.d file for NginX `/etc/int.d/nginx`.

I had mine already there but it may be that it was left over from
prev. NginX installation. Anyway if you need one
create it `sudo nano /etc/int.d/nginx` and paste:

```bash
#!/bin/sh

### BEGIN INIT INFO
# Provides:          nginx
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the nginx web server
# Description:       starts nginx using start-stop-daemon
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/nginx
NAME=nginx
DESC=nginx

# Include nginx defaults if available
if [ -f /etc/default/nginx ]; then
        . /etc/default/nginx
fi

test -x $DAEMON || exit 0

set -e

. /lib/lsb/init-functions

test_nginx_config() {
        if $DAEMON -t $DAEMON_OPTS >/dev/null 2>&1; then
                return 0
        else
                $DAEMON -t $DAEMON_OPTS
                return $?
        fi
}

case "$1" in
        start)
                echo -n "Starting $DESC: "
                test_nginx_config
                # Check if the ULIMIT is set in /etc/default/nginx
                if [ -n "$ULIMIT" ]; then
                        # Set the ulimits
                        ulimit $ULIMIT
                fi
                start-stop-daemon --start --quiet --pidfile /var/run/$NAME.pid \
                    --exec $DAEMON -- $DAEMON_OPTS || true
                echo "$NAME."
                ;;

        stop)
                echo -n "Stopping $DESC: "
                start-stop-daemon --stop --quiet --pidfile /var/run/$NAME.pid \
                    --exec $DAEMON || true
                echo "$NAME."
                ;;

        restart|force-reload)
                echo -n "Restarting $DESC: "
                start-stop-daemon --stop --quiet --pidfile \
                    /var/run/$NAME.pid --exec $DAEMON || true
                sleep 1
                test_nginx_config
                start-stop-daemon --start --quiet --pidfile \
                    /var/run/$NAME.pid --exec $DAEMON -- $DAEMON_OPTS || true
                echo "$NAME."
                ;;

        reload)
                echo -n "Reloading $DESC configuration: "
                test_nginx_config
                start-stop-daemon --stop --signal HUP --quiet --pidfile /var/run/$NAME.pid \
                    --exec $DAEMON || true
                echo "$NAME."
                ;;

        configtest|testconfig)
                echo -n "Testing $DESC configuration: "
                if test_nginx_config; then
                        echo "$NAME."
                else
                        exit $?
                fi
                ;;

        status)
                status_of_proc -p /var/run/$NAME.pid "$DAEMON" nginx && exit 0 || exit $?
                ;;
        *)
                echo "Usage: $NAME {start|stop|restart|reload|force-reload|status|configtest}" >&2
                exit 1
                ;;
esac

exit 0
```

sources:

* http://stackoverflow.com/questions/2263404/what-package-i-should-install-for-pcre-devel
* https://www.digitalocean.com/community/articles/how-to-compile-nginx-from-source-on-an-centos-6-4-x64-vps
* http://extralogical.net/articles/howto-compile-nginx-passenger.html
* http://railscasts.com/episodes/335-deploying-to-a-vps 
* https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy



## Related scrapbook links

* https://github.com/equivalent/scrapbook2/blob/master/nginx.md

## other related links

* [how to remove headers on NginX level](https://stackoverflow.com/questions/10323331/remove-unnecessary-http-headers-in-my-rails-answers/27175020#27175020)
