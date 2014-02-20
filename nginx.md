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


#restrict access

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
    #   proxy_pass http:/0.0.0.0:3000
    #
  }                                                                                                                   
  
  # use error pages from public/500.html for this statuses
  error_page 500 502 503 504 /500.html;                                                                               
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
