# NginX shared configuration

NginX example of sharing (including) configuration

Source code is in `etc` folder (represents `/etc/`)

## about applicattion

* NginX configuration for application under Unicorn server (like Ruby on Rails), but 
  example of sharing configuration shown here will work on any.
* this app forces `https://` if visited from private domain and let's `http://` if from public domain

# source

* http://nginx.org/en/docs/ngx_core_module.html#include
* http://serverfault.com/questions/373578/how-can-i-configure-nginx-locations-to-share-common-configuration-options

server names / wildcards are explained in:

* http://nginx.org/en/docs/http/server_names.html#wildcard_names
