# Installing rbenv on Ubuntu machine

...or basically any Linux machine

Applications I'm using for this tutorial

```bash
sudo apt-get install git curl vim
```

instal dependencies:

```bash
sudo apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev
```

Download and install rbenv by running this in shell

```bash
cd ~
curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
```

Add `rbenv` to your `.bashrc

`vim ~/.bashrc` and add

```bash
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
```

next you need to load bashrc changes

```bash
. ~/.bashrc 
bash
```

If you are on Ubuntu 10.04 or 12.10, before you install ruby
you need to run:

```bash
rbenv bootstrap-ubuntu-10-04
rbenv bootstrap-ubuntu-12-04
rbenv bootstrap-ubuntu-12-10
```

This will install dependencies for ruby. You can check what the scripts are doing at:

https://github.com/fesplugas/rbenv-bootstrap/tree/master/bin

...and you can install those dependencies for not listed Ubuntu versions (e.g.: 13.10)

Install ruby of your choice

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

Install bundler

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

source

* http://railscasts.com/episodes/335-deploying-to-a-vps?view=comments
* https://github.com/sstephenson/ruby-build

