# whenewer gem (cron)

http://chinnaror.blogspot.co.uk/2014/03/rails-crontab-with-whenever-gem.html
https://github.com/javan/whenever/wiki/Output-redirection-aka-logging-your-cron-jobs


```
 RAILS_ENV=staging bundle exec whenever -s 'environment=staging'  # won't write anythnig 
  RAILS_ENV=staging bundle exec whenever -s 'environment=staging' -w  # write
  
```


to check cron seting 

```bash
crontab -l
```
