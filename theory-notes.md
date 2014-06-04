# Theory notes

Collection on 


URI - uniform resource identifier- generic referenc to resource.

URN -uniform resource name

URL uniform resource locator - is URI with network protocol (.html, ..json...)



CDN content delivery network...@todo google

## REST

**HATEOAS** hypermedia as the engine of application state - basicaly user shoul work with active links not hatdcoded ones that may change. ... User chould discover links by using app

REST representative štáte transfer....HTTP for inter-computer comunication via resources based on uniq uri mapped by HTTP verbs GET, POST, PUT, DELETE to CRUD


API meditaiton layer  @todo page 027



## Deployment

* Generally, web apps are stored inside `/var/www` on Unix since the `/var` directory is designated for files that increase in size over time, which is the case with most web apps

## Scrum

User stories prioritized by product owner to release backlog.
Team than estimates user storis in backlog and prioritize them to sprints.

* Estimates in story points or  developer hours
* larger items to estimates can be brokend down and estimated as summary of chunks

Burndown chart @todo

sources 

* https://www.youtube.com/watch?v=XU0llRltyFM

## Kanban 

it's lean agile metodology (in our context) to improve development flow 

* kan ban (visual card) - visual representation of que that helps (not only) development 
team to visualize the workflow so that software delivery is in sync
* 2 - 4 week sprints of prioritized product backlog (by product owner) estimated 
by by Development team on which end there is deliverable software
* dayly status meeting (daily scrum)
* wip limit - for evry board step has task limit defined on how many task can be there (e.g. in review max = 2).
This limits partialy undone work and substain steady flow of new features (not batch feature delivery).
In other words it's better to have 2 tasks done, than 8 80% done

sources: 

* https://www.youtube.com/watch?v=0EIMxyFw9T8


## Unicorn

* proces based server
* Master proces is monitoring workers
* if one of workers take too much memory it will fork the process and kill the original one
* when deployed, Unicorn gracefully fork  & shut down workers for new code
* master wont kill process untill successfuly forked (this may cause issues as old proces 
may be still alive meaning old code is displayed)
* When all workers finish serving their current requests, the old master then dies, 
and our app is fully reloaded with new code

comperisant to Passanger
  *  only Passeanger enterprise (paid) suport restarting like this however 
  Passanger solution restart one by one therfore take les memory (Unicor tries to do that at once unless you
  set up init.d script to do that )

sources:

* https://github.com/blog/517-unicorn
* http://vladigleba.com/blog/2014/03/21/deploying-rails-apps-part-3-configuring-unicorn/
* http://www.justinappears.com/blog/2-no-downtime-deploys-with-unicorn/

## Puma 

* multi thread server (running multiple threads in a single process)
* rails  app must be thread safe

multi-thred server(puma) vs process-based server (unicorn)

* proces based - each instance take lives in own process => own cluster of memmory => can easily drain resources
* Thred based - won't use the same amount of memory to THEORETICALLY attain the same amount of concurrency.
* 

source:

* http://stackoverflow.com/questions/18575235/what-do-multi-processes-vs-multi-threaded-servers-most-benefit-from

## PosgreSQL

postgresql advantages over mysql:

* tables are created over transaction (if  creatin migration fail you can run it again) transactional schema changes 
* type protection will not execute query (e.g if you set incorect date format) 
* if you create record where you set wrong string as date format, record is saved and date is populated with bullshit

# Notes from screencasts

### [PeepCode 055 - F. Hwang](http://pluralsight.com/training/courses/TableOfContents?courseName=play-by-play-francis-hwang&highlight=geoffrey-grosenbach_play-by-play-francis-hwang-m01!francis-hwang_play-by-play-francis-hwang-m02!francis-hwang_play-by-play-francis-hwang-m03#play-by-play-francis-hwang-m01)

* Purpose of refactoring is not to reduce code but to comunicate more clearly
* there is no good reason why to use MySQL for Rails project. If you concern about speed rather use Mongo
