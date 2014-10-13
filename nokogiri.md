

```ruby
doc = Nokogiri::HTML.parse(<<-HTML_END)
<div class="heat">
   <a href='http://example.org/site/1/'>site 1</a>
   <a href='http://example.org/site/2/'>site 2</a>
   <a href='http://example.org/site/3/'>site 3</a>
</div>
<div class="wave">
   <a href='http://example.org/site/4/'>site 4</a>
   <a href='http://example.org/site/5/'>site 5</a>
   <a href='http://example.org/site/6/'>site 6</a>
</div>
HTML_END

l = doc.css('div.heat a').map { |link| link['href'] }
```

source: http://stackoverflow.com/questions/856706/extract-links-urls-with-nokogiri-in-ruby-from-a-href-html-tags


#installing nokogiri or OSX

if you have problem with `libiconv` not beeing present do 

```
xcode-select --install
```

this may happen during OSX updates as well, 
