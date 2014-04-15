# Jenkins CI for Rails 4, RSpec, Cucumber, Selenium

In this article we will setup CI system on fresh Ubuntu 12.04. I'm basing my manual a lot on 
Dan Maclains blog on configuring Jenkins:

* http://rails-jenkins.danmcclain.net/#1
* http://danmcclain.net/blog/2011/11/22/using-jenkins-with-rails/

## Instalation

First install some general stuff:

```sh
sudo apt-get install git curl vim
```

We will begin by adding Jenkins to trusted keys + source list and installing it:

```sh
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
```

This will create Jenkins user, init.d script, and starts jenkins on port `8080`
So you should be able to access Jenkins from `http://localhost:8080/`.



## Jenkins Plugins

We need to add several plugins to Jenkins. Open your web-browser and visit `http://localhost:8080/pluginManager`.
Click on `Available` tab and search for `Git`, `Github` plugin and install. 

Next go to `http://localhost:8080/configure`

In **Git plugin** section set the Global Config `user.name` Value and Global Config `user.email` Value

In the Shell section set `Shell executable` to `/bin/bash` 


## Jenkins system user configuration

We will add `rvm` to Jenkins user, generate ssh-keys and add them to github

```sh
sudo su - jenkins     # login as Jenkins user

# add rvm to Jenkins
bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)

# generate ssh-keys for jenkins
ssh-keygen

# copy your public key and add it to desired Github profile
vim ~/.ssh/id_rsa.pub

exit                  # leave jenkins user
```

## Configuration for Jenkins run


```sh
echo "export rvm_trust_rvmrcs_flag=1" >> /tmp/.rvmrc
sudo mv /tmp/.rvmrc  /var/lib/jenkins/
chmod 755 /var/lib/jenkins/.rvmrc
```

```sh
echo "[ -s "/var/lib/jenkins/.rvm/scripts/rvm" ] && source "/var/lib/jenkins/.rvm/scripts/rvm" >> /tmp/.bashrc
sudo mv /tmp/.bashrc /var/lib/jenkins/
chmod 755 /var/lib/jenkins/.bashrc
```

## Jenkins item

![First step](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2014/jenkins-ci-step-1.png)

Visit Jenkins website `http://localhost:8080/` and choose to `New item`, name the item (e.g.: run test on master), 
select `Build a free-style software project` option and submit the form.

![Second step](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2014/jenkins-ci-step-2.png)


At this point we will skip the Github project item (green arrow), select `git` as your `Source Code Management`, 
fill in `Repository URL` (Use the `git@github.com/repo.git` format) and provide branch (e.g.: `*/master`). You can choose whatewer branch you want, if you want to apply thit to all branches you can use `**`, but I rather recommend to crate defferent items for different branches.

In Build section `Add bulid step`, select `execute shell` and fill in `command` textarea with: 

```
source ~/.bashrc                                         # Loads RVM
cd .                                                     # Loads the RVM environment set in the .rvmrc file

rvm current                                              # will display current rvm (debugging purpouse)

cp /var/lib/jenkins/my_database.yml config/database.yml  # copy database yaml to project

bundle install                                           # Installs gems

TEST_ENV_NUMBER=995 RAILS_ENV=test bundle exec rake db:drop
TEST_ENV_NUMBER=995 RAILS_ENV=test bundle exec rake db:create
TEST_ENV_NUMBER=995 RAILS_ENV=test bundle exec rake db:hstoreize
TEST_ENV_NUMBER=995 RAILS_ENV=test bundle exec rake db:migrate

TEST_ENV_NUMBER=995 RAILS_ENV=test bundle exec rake db:schema:load

TEST_ENV_NUMBER=995 rspec spec

export DISPLAY=:0;                                      # eneble jenkins to run firefox selenium websteps
                                                        # on screen

TEST_ENV_NUMBER=995 cucumber    # if you use cucucmber
TEST_ENV_NUMBER=995 spinach     # if you use spinach
```

in case you are wondering what the  `TEST_ENV_NUMBER=995` means I'll explain that later.













