
# Ruby, Rubygems & bash on Windows

git & bash: http://git-scm.com/download/win
ruby : http://rubyinstaller.org/

### solving the SSL Error When installing rubygems

```
SSL Error When installing rubygems, Unable to pull data from 'https://rubygems.org/...
```

solution

* 1 discover where are rubygems installed `gem which rubygems` ( `# Ruby21/lib/ruby/2.1.0/rubygems.rb` )
* 2 download https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem
* 3 save it to `./2.1.0/rubygems/ssl_certs` (`Ruby21/lib/ruby/2.1.0/rubygems/ssl_certs`)

source: https://stackoverflow.com/questions/19150017/ssl-error-when-installing-rubygems-unable-to-pull-data-from-https-rubygems-o/27298259#27298259
