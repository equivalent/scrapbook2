
# Inspecting memcached keys

```
telnet 127.0.0.1 11211

stats items
```

this will give you memcached slobs (something like a cluster of keys)
you can inspect slob with :

```
stats cachedump 20 100
```

first argument is slob number(20), second argument is number of lines (100)

to exit tellnet

```
ctrl + ]
quit
```

source:
* http://www.justhacking.com/inspecting-memcached-content
* http://superuser.com/questions/486496/how-do-i-exit-telnet

# set memory size limit

http://code.google.com/p/memcached/wiki/NewConfiguringServer
