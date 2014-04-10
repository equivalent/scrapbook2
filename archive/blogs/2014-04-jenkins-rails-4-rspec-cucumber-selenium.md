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
sudo apt-get install git
```

this will create Jenkins user, init.d script, and starts jenkins on port `8080`


## Configure Jenkins

After instalation you should be able to access Jenkins from `http://localhost:8080/`. 

We need to add several plugins to Jenkins. Open your web-browser and visit `http://localhost:8080/pluginManager`.
Click on `Available` tab and search for `Git`, `Github` plugin and install. 

Next go to `http://localhost:8080/configure`

In **Git plugin** section set the Global Config `user.name` Value and Global Config `user.email` Value

In the Shell section set `Shell executable` to `/bin/bash` 








