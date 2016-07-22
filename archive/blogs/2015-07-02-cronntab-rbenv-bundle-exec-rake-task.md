# cron rbenv bundle exec rake task

keywords: cron, crontab, Ubuntu 14.04, rbenv, RACK_ENV, RAILS_ENV, Ruby
2.2.2, Rails backgroud job

## The example

Let say we have a `deploy` user and we want to have an automated rake task execution that would proces some events every minute.

We could use [whenever](https://github.com/javan/whenever) gem or some other gem altering `crontab` or behaving similar to `cron` ([daemons gem](https://github.com/thuehlinger/daemons)) but
this project is too small or VM has too litle memory or project is too not-important so we want to keep it simple.

Our server deploy user already has
[rbenv](https://github.com/sstephenson/rbenv) installed
(http://www.eq8.eu/blogs/4-installing-rbenv-on-ubuntu-machine) and we
already have our project in folder `~/apps/myapp`

The task that we want cron to process is `RACK_ENV=production bundle exec rake event:process`

*note: `RACK_ENV` is similar to `RAILS_ENV`. In my example I'm using
simple [Sinatra](http://www.sinatrarb.com/) app therefore I'm passing `RACK_ENV` to
`ActiveRecord::Base`*


## Set up cron

To setup cron job for user `deploy` you do:

```bash
crontab -u deploy -e
```

And we add:

```bash
* * * * * PATH=$PATH:/usr/local/bin && bash -lc "cd /home/deploy/apps/myapp && RACK_ENV=production bundle exec rake event:process"
```

Obviously the  `* * * * *` is a crontab scheduling syntax (run something every minute) and you can learn
abaut the values anywhere (e.g. http://kvz.io/blog/2007/07/29/schedule-tasks-on-linux-using-crontab/), this is outside the topic of our article.

But why all those command arguments ? Well it's tricky.

You see, apparently cron has limited access to `$PATH` and doesn't know
about your user's `bash` configuration (it's not triggering as bash
env).

So you need to extend the `PATH` and then trigger your command via `bash -lc` which will load `.bash_profile` therefore your ands `rbenv` location and furtherly extends `$PATH` with `rbenv`. `bash -lc` executes only one command that's why the remaining part is in quotes `" "`

From what I've seen playing around with our curl example  (but I may be wrong on this)  because we load the `.bash_profile` the ENV changes yet again therefore `RACK_ENV=production` (or `RAILS_ENV=production`) must be inside the quotes othervise it's not going to be passed to `rake`.

*note: Of course you can setup cron on whatever user or as a global cron job
(`crontab -e`) but then your `rbenv` needs to be installed globaly on
system not on a user.*

### .bash_profile is not the same as .bashrc

if you have lines:

```bash
export RBENV_ROOT="${HOME}/.rbenv"

if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi
```

... in `.bashrc` and not in  `.bash_profile` this will not work (unless
your `.bash_profile` is loading `bashrc`. The reason is (like I said
before) `bash -lc` loads `.bash_profile` context.

To solve this either load `.bash_profile` form `.bashrc` or other way
around.

```bash
# in .bashrc
. ~/.bash_profile
```

### cron log

If you need further debugging what is going worng check:

```bash
grep CRON /var/log/syslog
tail -f /var/log/syslog
```

### Even more cron rbenv debugging

For me helpfull was to add something like this to crontab:

```bash
* * * * * PATH=$PATH:/usr/local/bin && bash -lc "cd /home/deploy/apps/myapp && RACK_ENV=production bundle exec rake event:process > /tmp/lets_figure_this_out.txt"
```

To check what ENV variables are actually set:

```bash
* * * * * bash -lc "env > /tmp/env.txt"
```

...and check if you have something like this

```bash
PATH=/home/app/.rbenv/shims:/home/app/.rbenv/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/app/bin
```

(read more here: http://www.relativkreativ.at/articles/running-ruby-scripts-from-within-a-cron-job-in-an-rbenv-environment)

Just please remember to remove those lines when you're finished


## Last note

I'm not an expert on Cron or Bash I'm just a Ruby developer trying to
get stuff done. I may be wrong on some stuff mentioned in here, please
correct me in comment or make a Pull Request to the article.

https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2015-07-02-cronntab-rbenv-bundle-exec-rake-task.md

## Source of information

* http://www.relativkreativ.at/articles/running-ruby-scripts-from-within-a-cron-job-in-an-rbenv-environment
* http://stackoverflow.com/questions/8434922/ruby-script-using-rbenv-in-cron
* http://tutorials.jumpstartlab.com/topics/systems/automation.html
* https://help.ubuntu.com/community/CronHowto
* http://askubuntu.com/questions/23009/reasons-why-crontab-does-not-work
* http://askubuntu.com/questions/56683/where-is-the-cron-crontab-log
