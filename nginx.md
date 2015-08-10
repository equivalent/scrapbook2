# examples 
[jenkins nginx
configurations](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy)
http://unicorn.bogomips.org/examples/nginx.conf


# use  NginX  just to list items in dir


   server {
       listen 80
       root /tmp/blah
       autoindex on;
   }

# Rails force_ssl causes NginX to do infinite loop

more info here  https://github.com/equivalent/scrapbook2/blob/master/archive/mini-blogs/2014-12-16-force-ssl-nginx-infinite-loop.md

# NginX running out of server name size

if you ever get error:

```
could not build the server_names_hash,
you should increase server_names_hash_bucket_size: 32
```

it just means that you defined too long or noo many server names for default nginx setup.

all you have to do is in your `/etc/nginx/nginx.conf` tell 

```
http {
    server_names_hash_bucket_size  64;
```

... 32 is nginx default

source: http://nginx.org/en/docs/http/server_names.html

# Dont show NginX version in header 

you can see this information in firefox request 

```
Server	nginx/1.4.5  #without option bellow  
Server	nginx        #with    option bellow  
```

```
# /etc/nginx/ngnix.conf
server_tokens off;
```

# Remove X-Runtime from header


To remove the additional banners added by other modules, you
will need to install the 3rd party module HttpHeadersMoreModule
and add the following lines in the "http" block of the nginx.conf

```
# set and clear output headers
more_clear_headers 'X-Powered-by' 'X-Runtime';
```

or directly in Rails app


```ruby
# config/application.rb  ...or 
# config/enviroments/production.rb  

  config.middleware.delete(Rack::Runtime) # removes X-Runtime header
```

...but better solution is:

```ruby
# lib/stealth_middleware.rb
class StealthMiddlware
  def initialize(app)
    @app = app
  end
  def call(env)
    status, headers, body = @app.call(env)
    headers.delete('X-Runtime')
    [status, headers, body]
  end
end

# config/application.rb or config/enviroments/production.rb
require './lib/stealth_middlware'
config.middleware.insert_before 'Rack::Runtime', 'StealthMiddlware'
```

https://github.com/rails/rails/issues/1043


# nginx example with ssh

https://gist.github.com/equivalent/9352734  (stolen from https://gist.github.com/Austio/6399964)


# nginx test configurantion

```
sudo /usr/sbin/nginx  -t

```

(depend where your nginx executabl is located)


# nginx variables


```
$host             #  mysite.com?foo=bar&car=car
$html_host
$request_uri      #  ?foo=bar&car=car
```

Examlpe

```
    if ($server_port = 80) {
        rewrite ^ https://$host$request_uri permanent;
    }
```


# restart, stop, start

~~~bash
ps aux | egrep '(PID|nginx)'
#kill main one
sudo  /opt/nginx/sbin/nginx

#or

sudo /etc/init.d/nginx restart

# the best

sudo service nginx restart
                   status
                   start
                   stop
~~~


# several servers NginX

you can have several sites hosted managed by Nginx

```
   server {
        listen 80 default;  # he will have the port 80 by default
        server_name foo1
        root /home/tomi/projects/foo1;
        index  index.html index.htm;
    }
    
    server {
        listen 80;
        listen 81;          # localshost:81 will trigger this
        server_name foo2
        root /home/tomi/projects/foo2;
        index  index.html index.htm;
    }
```


# nginx with multiple Self signed certificates for same IP 

stolen from: https://www.digitalocean.com/community/articles/how-to-set-up-multiple-ssl-certificates-on-one-ip-with-nginx-on-ubuntu-12-04
http://nginx.org/en/docs/http/configuring_https_servers.html#sni

first you need to check if your nginx supports SNI (single name identifier)

```bash
nginx -V 

# or   /opt/nginx/sbin/nginx -V

# and it should say  TLS SNI support enabled

```

than you can generate certificates on separate domains


```bash
# location depending if you have repo nginx(/etc/nginx) or you built it yourself(/opt/nginx)

mkdir -p /etc/nginx/ssl/my_appication_name.com/
mkdir -p /etc/nginx/ssl/my_appication_name.london/


cd /etc/nginx/ssl/my_appication_name.com/
sudo openssl genrsa -des3 -out server.key 1024          # generate private server key with password
sudo openssl req -new -key server.key -out server.csr   # generate signing request form key
                                                        # this will promt you to fill in some inforation
                                                        # about "sign" company
                                                        # most import is the Common Name !!! 
# Common Name []:my_application_name.com                # enter here the official name, domain or IP 

sudo cp server.key server.key.org
sudo openssl rsa -in server.key.org -out server.key     # remove password from key

sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt  # sign the certificate (365 days)


# same for the other tld
cd /etc/nginx/ssl/my_appication_name.london/
sudo openssl genrsa -des3 -out server.key 1024 
sudo openssl req -new -key server.key -out server.csr
# Common Name []:my_application_name.london
sudo cp server.key server.key.org
sudo openssl rsa -in server.key.org -out server.key 
sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

```

now in your virtual host 

```bash
sudo vim /etc/nginx/sites-available/my_appication_name.com


server {
        listen   443;                       #this will tell to listen to ssl
        server_name my_appication_name.com;

        root /usr/share/nginx/www;
        index index.html index.htm;

        ssl on;
        ssl_certificate /etc/nginx/ssl/my_appication_name.com/server.crt;   # use the .crt not the .csr
        ssl_certificate_key /etc/nginx/ssl/example.org/server.key;          # the one without the password
}

sudo vim /etc/nginx/sites-available/my_appication_name.london


server {
        listen   443;                 
        server_name my_appication_name.london;

        root /usr/share/nginx/www;
        index index.html index.htm;

        ssl on;
        ssl_certificate /etc/nginx/ssl/my_appication_name.com/server.crt;
        ssl_certificate_key /etc/nginx/ssl/example.org/server.key;
}
```

you have to have loading of those virtual host fileas activated in your main nginx config `/etc/nginx/conf/nginx.conf` !!

or 

```bash
sudo ln -s /etc/nginx/sites-available/my_appication_name.com /etc/nginx/sites-enabled/my_appication_name.com
sudo ln -s /etc/nginx/sites-available/my_appication_name.london /etc/nginx/sites-enabled/my_appication_name.london
```

finally restartyour nginx

Note that `my_application.com` and `www.my_application.com` are two different things ! 

to test this in Curl trigger `curl -kvI https://my_application.com`

**note** linux standart is to put certificates to `/etc/ssl/certs` and private keys to `/etc/ssl/private`


# signing real certificate

When you have the real certificate you need to "chain" the certificate file with  *Intermediate Certificates* and with *Root Certificate*

create file `mydomain.crt` :

```
-----BEGIN CERTIFICATE-----
The generated cert file
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
Intermediate Certificate
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
Root Certificate
-----END CERTIFICATE-----
```

example

[Globalsign Intermediate certificate](https://support.globalsign.com/customer/portal/articles/1219303-organizationssl-intermediate-certificates), [Globalsign root certificate](https://support.globalsign.com/customer/portal/articles/1426602-globalsign-root-certificates)

and you can test it on https://sslcheck.globalsign.com/en_US/sslcheck


When you renewing certificate just replace the old cert part with new
cert (keep root and intermed) 


**note2**

for geotrust certificate all you need is one intermediate
certificate as browsers has a list of "trusted" root certificates (e.g. Geotrust is one of them).

For example for "Geotrust True BusinessID Wildcard " you need only "True Business ID Wildcard RSA-SHA2 Intermediate CA" listed  under SHA-2 Root. 

The link to this root should be in the email

https://knowledge.geotrust.com/support/knowledge-base/index?page=content&id=AR1421


# debugging ssl certificates


1. check content of csr and crt file if they are for same thing (check
   subject CN)

https://redkestrel.co.uk/articles/openssl-commands/#view-csr

```
openssl x509 -noout -text -in my-domain.crt
# ...and 
openssl req -in my-domain.csr -noout -text
# ...should have similar subject (specially CN ) :

#Certificate Request:
#    Data:
#        Version: 0 (0x0)
#        Subject: C=UK, ST=Berkshire, L=Reading, O=Bla Bla Ltd,OU=bla, CN=my-domain.tld/emailAddress=blabla@bla.bla
# .....
```

2. Check an MD5 hash of the CRT to ensure that it matches with what
is in a private key

```bash
openssl x509 -noout -modulus -in certificate.crt | openssl md5

openssl rsa -noout -modulus -in privateKey.key | openssl md5
```

http://stackoverflow.com/questions/26191463/ssl-error0b080074x509-certificate-routinesx509-check-private-keykey-values


#restrict access / basic auth


    location / {

      auth_basic "You shall not pass !!!";
      auth_basic_user_file /etc/nginx/security/htpasswd;

      # if you are proxy passing to web-server than don't forgot
      # ...
      proxy_set_header   Authorization "";
      # ...
    }



restrict access: http://wiki.nginx.org/NginxHttpAuthBasicModule#auth_basic_user_file



# nginx config files

The main nginx config file is `/etc/nginx/nginx.conf` but keep this for system preferences. Inside of it you have
a line:

```
include /etc/nginx/sites-enabled/*; 
```

...which include configurations for your sites. 

NginX by default takes the `/etc/nginx/sites-enabled/default` one as the main site.



# nginx with unicorn rails

as seen in: http://railscasts.com/episodes/293-nginx-unicorn , https://github.com/railscasts/293-nginx-unicorn

```bash
# /etc/nginx/sites-enabled/default

# this translates to to the proxypas http://unicorn
upstream unicorn {

  # unicorn server is pointing socket to /tmp/unicorn.my_cool_app_name.sock
  server unix:/tmp/unicorn.my_cool_app_name.sock fail_timeout=0;                                                           
}
                                                                                                                      
server {

  server_name  my_cool_app_name;                                                                                           

  # public & precompiled assets
  root /home/deploy/apps/app_name/current/public;   
  
  # log
  access_log  /var/log/nginx/localhost.access.log;                                                                    
  
  # this is telling NginX to try to fetch
  #   
  #  1  /home/deploy/.../current/public/index.html
  #  2  /home/deploy/.../current/public/whatever_requested
  #  3  unicorn location, wich eqls to unicorn socket
  #
  try_files $uri/index.html $uri @unicorn;                                                                            
  
  # unicorn location
  location @unicorn {                                                                                                 
    proxy_pass http://unicorn;
    
    # if you want to try this with webrick you can do 
    #   
    #   proxy_pass http://0.0.0.0:3000
    #
  }                                                                                                                   
  
  # use error pages from public/500.html for this statuses
  error_page 500 502 503 504 /500.html;                                                                               
}  

```


# simple static index.html file configuration

```
# /etc/nginx/sites-enabled/default
server {
  # if you running Varden you may need option below 
  # listen   80;

  server_name  my_app_name;

  access_log  /var/log/nginx/localhost.access.log;

  location / {
    root /home/deploy/apps/my_app_name/;
    index  index.html index.htm;
  }
}
```

#x forwarded for

!!!!!unfinished

realy good example ngnix.conf file is at http://brainspl.at/nginx.conf.txt
http://forum.nginx.org/read.php?2,97154
https://www.chiliproject.org/boards/1/topics/545

```bash
#log_format  main  '$remote_addr - $remote_user [$time_local]"$request" '
#                  '$status $body_bytes_sent "$http_referer" '
#                  '"$http_user_agent" "$http_x_forwarded_for"';

```

!!!! unfinished







netstat -anp|grep 3000  
[emerg]: bind() to unix:/tmp/nginx-staging.sock failed (98: Address already in use)
