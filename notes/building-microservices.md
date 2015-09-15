* architect in software industry is not like building architect, he dont
  guarantee every line of code like building architect guarantee each
construction line. The title is missleading. Software architect is like
town planer in game Sim City. Making sure that residential buildung are
next to shops, not tha t hey have exactly some size.

* comunication between microservice 
  * synch. vs asynch. colaboration
  * orchestrated vs choreographed approach
  * register event at parent service
  * RPC (RemoteProcedureCalls)
    * binary like drb (distributed ruby) or java RMI
      triggers binary on diferent machine like it was local
      but they introduce technology coupling (restrict tech.)



* micoservice should keep in mind the bigger picture
* websocets 
* message broker rabitmq 
* atom feed

# reporting
* when you need to do huge load calls ( reporting ) and you want to
  avoid lot of calls you can expose batch api that would accept huge
request, return an
HTTP 202 response code, indicating that the request was accepted but has
not yet been
processed. The calling system could then poll the resource waiting until
it retrieves a 201
Created status, indicating that the request has been fulfilled, and then
the calling system
could go and fetch the data. This would allow potentially large data
files to be exported
without the overhead of being sent over HTTP; instead, the system could
simply save a
CSV file to a shared location.

   * revers proxy can do caching too
* data pumps (cron job that will write directly to reporting DB)
* event data pumps (each event change trigger proprietary call to
  reporting server) (scale essues)
* backup data pumps (like Netflix, they pull s3 objects backups to
  reporting hadoop server - SSTable and s3 object store. 
 Aegisthus projec )

# deploy

Options :
  * one repository of all artefacts + one one ci server that builds when
    any artefact changes (godd in beginnings when one team is doing
everything)
  * one repository of all artefacts + one CI server that knows the
    maping what artefact change would deploy only that artefact (better
but too much coupling)
  * separate repository for each artefact + one CI server that would
    deploy just one artefact
 

When the application is more mature Aim for one artefact to go through
entire CI pipeline (fast test, slow tests, user interface tests,
performance test deployed) not multiple


