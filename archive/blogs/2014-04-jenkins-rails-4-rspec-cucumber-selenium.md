# Jenkins CI for Rails 4, RSpec, Cucumber, Selenium

In this article we will setup CI system on fresh Ubuntu 12.04. Now there are several articles on configuring Jenkins
and I will be using here a lot of stuff mentioned in [Dan Maclains presentation on configuring Jenkins](http://rails-jenkins.danmcclain.net/#1). The reason I'm writing (or rewriting) my own manual is that I needed
some extra steps not mentioned in Dans presentation & that I find it much easier to fallow blog article than presentation
for my personal use.


## Instalation

We will begin by adding Jenkins to trusted keys + source list and installing it: 

```sh
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins

```

Some dependancies for plugins

```sh
sudo apt-get install git curl vim
```

this will create Jenkins user, init.d script, and starts jenkins on port `8080`


## Configure Jenkins

After instalation you should be able to access Jenkins from `http://localhost:8080/`. 

### Jenkins Plugins

We need to add several plugins to Jenkins. Open your web-browser and visit `http://localhost:8080/pluginManager`.
Click on `Available` tab and search for `Git`, `Github` plugin and install. 

Next go to `http://localhost:8080/configure`

In **Git plugin** section set the Global Config `user.name` Value and Global Config `user.email` Value

In the Shell section set `Shell executable` to `/bin/bash` 


### Jenkins system user configuration

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

### Configuration for Jenkins run


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














