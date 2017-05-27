# Ubuntu 14.04 Ruby Rails C dependancy solution

Given you are running Ubuntu 14.04 and you are installing/upgrading some Ruby gems
(let sey Rails 4.2.4 gem, or RSpec, ...) and you get this error:

```
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    /home/tomi/.rvm/rubies/ruby-2.2.3/bin/ruby -r ./siteconf20151015-21730-1qh2hm1.rb extconf.rb
creating Makefile

make "DESTDIR=" clean

make "DESTDIR="
compiling generator.c
linking shared-object json/ext/generator.so
/usr/bin/ld: cannot find -lgmp
collect2: error: ld returned 1 exit status
make: *** [generator.so] Error 1

make failed, exit code 2

Gem files will remain installed in /home/tomi/.rvm/gems/ruby-2.2.3@maze_magic/gems/json-1.8.3 for inspection.
Results logged to /home/tomi/.rvm/gems/ruby-2.2.3@maze_magic/extensions/x86_64-linux/2.2.0/json-1.8.3/gem_make.out
An error occurred while installing json (1.8.3), and Bundler cannot continue.
Make sure that `gem install json -v '1.8.3'` succeeds before bundling.
```

run:

```
sudo apt-get install libgmp-dev
```

or

```
sudo apt-get install libgmp3-dev
```


should solve the problem.

* http://stackoverflow.com/questions/29317640/gem-install-rails-fails-on-ubuntu/32965803#32965803
