

# escaping XML

... sanitizing xml, srip xml from special chars


strip XML from `^C` (control C)

```
value = value.encode(:xml => :text)  # remove &<>

"<node attr=#{my_string.encode(:xml => :attr)} />"
# => <node attr="this is &quot;my&quot; complicated &lt;String&gt;" />

"<node>#{my_string.encode(:xml => :text)}</node>"
# => <node>this is "my" complicated &lt;String&gt;</node>
```

more : https://gist.github.com/coffeejunk/3827905

```
value = value.gsub(/\002|\003/, '')  # remove ^C
```

# Spreadsheet Formula Injection prevention

```
  def secure_xls_cell(cell_value)
    cell_value[0] = "'=" if cell_value[0] == '='
    cell_value
  end
```


# check xml for errors

in ruby 

```ruby
Nokogiri::XML('foo').errors
```

in linux

```
xmllint my_file.xml
```
