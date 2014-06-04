# Theory notes

Collection on 


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


## PosgreSQL

postgresql advantages over mysql:

* tables are created over transaction (if  creatin migration fail you can run it again) transactional schema changes 
* type protection will not execute query (e.g if you set incorect date format) 
* if you create record where you set wrong string as date format, record is saved and date is populated with bullshit

# Notes from screencasts

### [PeepCode 055 - F. Hwang](http://pluralsight.com/training/courses/TableOfContents?courseName=play-by-play-francis-hwang&highlight=geoffrey-grosenbach_play-by-play-francis-hwang-m01!francis-hwang_play-by-play-francis-hwang-m02!francis-hwang_play-by-play-francis-hwang-m03#play-by-play-francis-hwang-m01)

* Purpose of refactoring is not to reduce code but to comunicate more clearly
* there is no good reason why to use MySQL for Rails project. If you concern about speed rather use Mongo
