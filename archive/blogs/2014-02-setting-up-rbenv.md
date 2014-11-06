# Installing rbenv on Ubuntu machine

...or basically any Linux machine

Applications I'm using for this tutorial

```bash
sudo apt-get install git curl vim
```

### instal dependencies:

```bash
sudo apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev
```

### Download and install rbenv 

NOTE: If you reinstalling `rbenv` you may need to explicitly specify `RBENV_ROOT` before running instaling curl bash

To install rbenv run this in terminal:

```bash
cd ~
curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
```


Add `rbenv` to your `.bashrc

`vim ~/.bashrc` and add

```bash
export RBENV_ROOT="${HOME}/.rbenv"
# export RBENV_ROOT="/opt/rbenv/" # some developers prefare this option I highly recommend 
                                  # to instal rbenv to home folder of deploy user as it's 
                                  # convention 

if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi
```

next you need to load bashrc changes

```bash
. ~/.bashrc 
bash
```

If you are on Ubuntu 10.04, 12.04 or 12.10, before you install ruby
you need to run:

```bash
rbenv bootstrap-ubuntu-10-04
rbenv bootstrap-ubuntu-12-04
rbenv bootstrap-ubuntu-12-10
```

This will install dependencies for ruby. You can check what the scripts are doing at:

https://github.com/fesplugas/rbenv-bootstrap/tree/master/bin

...and you can install those dependencies for not listed Ubuntu versions (e.g.: 13.10)

### Install ruby of your choice

```bash
rbenv install 2.1.1
```

...this will take some time so go grab a Snickers

if you get message  `ruby-build: definition not found: 2.1.1`, `cd` to 
the `rbenv` folder and do `git pull origin master`.

This is either located in `~/.rbenv` or `/opt/rbenv`

Set your newly installed ruby as global (default)

```bash
rbenv global 2.1.1
```

To check what is the current global ruby version

```bash
rbenv version
# => 2.1.1
```

to list all rbenv versions:

```bash
rbenv versions
```

### Install bundler

```bash
rbenv exec gem install bundler  --no-ri --no-rdoc
```

and run rehash, so that the change is pickend up

```bash
rbenv rehash
```

if you have any other questions just run 

```bash
rbenv help
```

## rbenv update Ruby version

let say new ruby version came up (in my case 2.1.2) and I want to upgrade it 

First check if you have your desired version in your already existing ruby-build list

```bash
rbenv install --list
```

if not you need to pull most recent `rbenv` & `ruby-build` updates with git from `rbenv` github repo to
location where is your `rbenv` installed (yes correct your `rbenv` is just collection of git repos)

```bash
cd  ~/.rbenv  # rbenv install location (...or /opt/rbenv/)
git pull # will pull rbenv repo

cd plugins/ruby-build/
git pull # will pull recent ruby builds
```

Now you can install your desired Ruby version

```bash
rbenv install --list  # should now include new ruby version
rbenv install 2.1.2
```

You will have to install `bundler` and `rvm rehash` again.

Now you can remove old ruby to save disk space

```bash
rbenv uninstall 2.1.1
```

source

* http://railscasts.com/episodes/335-deploying-to-a-vps?view=comments
* https://github.com/sstephenson/ruby-build
* http://stackoverflow.com/questions/23702954/rbenv-install-list-does-not-list-version-2-1-2

## Recommendations

### eval bundle problem

if your deployment with Capistrano or Mina fails on `bundle: not found` there is an easy solution mentioned here
http://stackoverflow.com/questions/15379618/capistrano-deploy-failing-error-for-rails-bundle-not-found

in your `.bashrc` file place :

```
eval "$(rbenv init -)"
```

...under the rbenv `$PATH` definition
