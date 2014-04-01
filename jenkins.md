http://rails-jenkins.danmcclain.net/#1


### build command 

```
source ~/.bashrc                                         # Loads RVM
cd .                                                     # Loads the RVM environment set in the .rvmrc file

cp /var/lib/jenkins/my_database.yml config/database.yml 
 
bundle install           # Installs gems

# RAILS_ENV=test bundle exec rake db:create
# RAILS_ENV=test bundle exec rake db:hstoreize
RAILS_ENV=test bundle exec rake db:migrate

rspec spec

## If you want html output
#   rm -rf jenkins && mkdir jenkins
#   SPEC_OPTS="--format html" rspec spec > jenkins/rspec.htm 

export DISPLAY=:0;                                      # eneble jenkins to run firefox


cucumber

spinach

```
