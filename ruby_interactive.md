

# Ruby's -e, -n and -p switches

```bash

ps ax |ruby -ne 'puts $_.split.first if $_ =~ /top/'

echo "eats, shoots, and leaves" | ruby -pe '$_.gsub!("e", "a")'^

echo "foo\nbar\nbaz" | ruby -ne 'BEGIN { i = 1 }; puts "#{i} #{$_}"; i+= 1'

sudo docker exec -it $(sudo docker ps | ruby -ne 'puts $_.split.first if $_ =~ /resque/') bash

```


source: https://robm.me.uk/ruby/2013/11/20/ruby-enp.html



