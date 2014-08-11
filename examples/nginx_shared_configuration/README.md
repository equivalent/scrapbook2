# NginX shared configuration

NginX example of sharing (including) configuration

Source code is in `etc` folder (represents `/etc/`)

## about

* configuration for unicorn server application (like Ruby on Rails).
* this app is forced to `https://` if wisited from private domain and let's `http://` if from public domain

# source

* http://nginx.org/en/docs/ngx_core_module.html#include
* http://serverfault.com/questions/373578/how-can-i-configure-nginx-locations-to-share-common-configuration-options

server names / wildcards are explained in:

* http://nginx.org/en/docs/http/server_names.html#wildcard_names
