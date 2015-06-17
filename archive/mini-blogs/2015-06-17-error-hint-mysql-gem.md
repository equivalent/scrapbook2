# Rails mysql gem (`>= 2.9.0`) throwing error `checking for mysql_query() in -lmysqlclient... no` 

My settup: 

* Ubuntu 14.04
* Rails 4.2.x
* Ruby 2.2.0

### Error:

```
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    /home/tomi/.rvm/rubies/ruby-2.2.0/bin/ruby -r ./siteconf20150617-4359-1xygr4t.rb extconf.rb 
checking for mysql_query() in -lmysqlclient... no
checking for main() in -lm... yes
checking for mysql_query() in -lmysqlclient... no
checking for main() in -lz... yes
checking for mysql_query() in -lmysqlclient... no
checking for main() in -lsocket... no
checking for mysql_query() in -lmysqlclient... no
checking for main() in -lnsl... yes
checking for mysql_query() in -lmysqlclient... no
checking for main() in -lmygcc... no
checking for mysql_query() in -lmysqlclient... no
*** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of necessary
libraries and/or headers.  Check the mkmf.log file for more details.  You may
need configuration options.

Provided configuration options:
	--with-opt-dir
	--without-opt-dir
	--with-opt-include
	--without-opt-include=${opt-dir}/include
	--with-opt-lib
	--without-opt-lib=${opt-dir}/lib
	--with-make-prog
	--without-make-prog
	--srcdir=.
	--curdir
	--ruby=/home/tomi/.rvm/rubies/ruby-2.2.0/bin/$(RUBY_BASE_NAME)
	--with-mysql-config
	--without-mysql-config
	--with-mysql-dir
	--without-mysql-dir
	--with-mysql-include
	--without-mysql-include=${mysql-dir}/include
	--with-mysql-lib
	--without-mysql-lib=${mysql-dir}/lib
	--with-mysqlclientlib
	--without-mysqlclientlib
	--with-mlib
	--without-mlib
	--with-mysqlclientlib
	--without-mysqlclientlib
	--with-zlib
	--without-zlib
	--with-mysqlclientlib
	--without-mysqlclientlib
	--with-socketlib
	--without-socketlib
	--with-mysqlclientlib
	--without-mysqlclientlib
	--with-nsllib
	--without-nsllib
	--with-mysqlclientlib
	--without-mysqlclientlib
	--with-mygcclib
	--without-mygcclib
	--with-mysqlclientlib
	--without-mysqlclientlib

extconf failed, exit code 1

Gem files will remain installed in /home/tomi/.rvm/gems/ruby-2.2.0@rails-framework-4.2/gems/mysql-2.9.1 for inspection.
Results logged to /home/tomi/.rvm/gems/ruby-2.2.0@rails-framework-4.2/extensions/x86_64-linux/2.2.0/mysql-2.9.1/gem_make.out

```

### solution:

```bash
sudo apt-get install  libmysqlclient-dev
```

if not try

```bash
 sudo apt-get install mysql-server
```
