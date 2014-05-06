http://rails-jenkins.danmcclain.net/#1

### cannot login 

if you manage to lock all of your users on Jenkins security (Been
there), just change `<useSecurity>true</useSecurity>` to
`<useSecurity>false</useSecurity>` in  `/var/lib/jenkins/config.xml` 

### restart jenkins

visit `http://Jenkins_url/restart`

or `sudo service jenkins restart`

https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy

### build command 

```
source ~/.bashrc                                         # Loads RVM
cd .                                                     # Loads the RVM environment set in the .rvmrc file

rvm current

cp /var/lib/jenkins/my_database.yml config/database.yml 
 
bundle install           # Installs gems

TEST_ENV_NUMBER=12 RAILS_ENV=test bundle exec rake db:drop
TEST_ENV_NUMBER=12 RAILS_ENV=test bundle exec rake db:create
TEST_ENV_NUMBER=12 RAILS_ENV=test bundle exec rake db:hstoreize
TEST_ENV_NUMBER=12 RAILS_ENV=test bundle exec rake db:migrate

TEST_ENV_NUMBER=12 RAILS_ENV=test bundle exec rake db:schema:load

TEST_ENV_NUMBER=12 rspec spec

## If you want html output
#   rm -rf jenkins && mkdir jenkins
#   SPEC_OPTS="--format html" rspec spec > jenkins/rspec.htm 

export DISPLAY=:0;                                      # eneble jenkins to run firefox
TEST_ENV_NUMBER=12 cucumber
TEST_ENV_NUMBER=12 spinach

```
