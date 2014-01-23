
# restart, stop, start

~~~bash
ps aux | egrep '(PID|nginx)'
#kill main one
sudo  /opt/nginx/sbin/nginx

#or


sudo /etc/init.d/nginx restart
~~~


#restrict access

restrict access: http://wiki.nginx.org/NginxHttpAuthBasicModule#auth_basic_user_file

nginx config:

~~~bash
cd /opt/nginx/conf/conf.d
~~~


#x forwarded for

!!!!!unfinished

realy good example ngnix.conf file is at http://brainspl.at/nginx.conf.txt
http://forum.nginx.org/read.php?2,97154
https://www.chiliproject.org/boards/1/topics/545

~~~~bash
#log_format  main  '$remote_addr - $remote_user [$time_local]"$request" '
#                  '$status $body_bytes_sent "$http_referer" '
#                  '"$http_user_agent" "$http_x_forwarded_for"';

~~~

!!!! unfinished







netstat -anp|grep 3000  
[emerg]: bind() to unix:/tmp/nginx-staging.sock failed (98: Address already in use)
