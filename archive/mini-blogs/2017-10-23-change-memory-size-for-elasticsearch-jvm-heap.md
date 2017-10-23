# Change memory size for elasticsearch 5 JVM heap


**Given**: your VM is on  ubuntu 16.04 
**And**: you had installed your ElasticSearch with command:

```
sudo apt-get install default-jre
sudo apt-get install default-jdk
cd /tmp
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" |
sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update && sudo apt-get install elasticsearch
sudo systemctl enable elasticsearch.service
```

**When** you are getting error:


```
sudo service elasticsearch status

● elasticsearch.service - Elasticsearch
   Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service;
enabled; vendor preset: enabled)
   Active: failed (Result: exit-code) since Mon 2017-10-23 06:29:14 UTC;
2s ago
     Docs: http://www.elastic.co
  Process: 27700 ExecStart=/usr/share/elasticsearch/bin/elasticsearch -p
${PID_DIR}/elasticsearch.pid --quiet -Edefault.path.logs=${LOG_DIR}
-Edefault.path.data=${DATA_DIR} -Edefault.path.conf=${CONF_DIR}
(code=exited, status=1/
  Process: 27696
ExecStartPre=/usr/share/elasticsearch/bin/elasticsearch-systemd-pre-exec
(code=exited, status=0/SUCCESS)
 Main PID: 27700 (code=exited, status=1/FAILURE)
```

**Then** you need to change default Java heap  memory size  for elastic
search (default is 2GB)


```bash
vim /etc/elasticsearch/jvm.options
```

...and change

```
# ...

-Xms2g
-Xmx2g

# ...
```

..to

```
# ...

-Xms200m
-Xmx200m

# ...
```

> this will change heap to 200 MB, you can decrease even more 


After this restart elasticsearch

```
sudo service elasticsearch start
sudo service elasticsearch status  # should be OK now
```


* https://www.elastic.co/guide/en/elasticsearch/reference/master/heap-size.html
* https://www.elastic.co/guide/en/elasticsearch/reference/5.5/settings.html

