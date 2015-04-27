# JSON array in html element data attribute

I was writing some view code today where jQuery would pick-up
values of button data attribute (array of ids) and make Ajax
calls to to server based on values.

What that Ajax call is is not important. The important part was
how to actually render array to a `data` html attribute.

I was thinking about doing something like:

```markup
<button data-document-ids="abcefg,efgabcd" />
```

...and on JS side just parse like:

```javascript
$('button').data('documentIds').split(',')
```

But why to reinvent the wheel again. There is already an established
JavaScript data format, ...you know, ... JSON :)

So I'll just put JSON to button `data` attribute and do something like


```javascript
JSON.parse($('button').data('documentIds'))
```

I'll show you the HTML piece soon, before that I want to point out
that jQuery is clever enough to actually translate the JSON string to
Array without me manualy saying `JSON.parse`.

All I have to do is:

```javascript
$('button').data('documentIds')
```

So here is my ruby code  that is generating HTML

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def button_of_ids
    ids = ['abcefg', 'efgabcd']
    content_tag :button, 'Choose Files', data: { "document-ids" => ids}
  end
end
```

```markup
<%= button_of_ids %>
```

...and it was working in browser ! :)

The shock came to me when I was writing a test for this. The HTML output
was like:

```markup
<button data-document-ids="[&quot;abcdefg&quot;,&quot;efgabcd&quot;]" />
```

It appears that jQuery is correctly translating the `&quot` to `"` and then
parsing the JSON

Try it here http://jsfiddle.net/estuqq26/1/  (tested with jQuery 1.9.1)

Code works, it seems reasonable (althought one my say it's rendering ugly HTML)

After few months from now (having this on production) I'll update this article
when I discover if it was a good idea or not

...anyway here are some references of people using it:

* http://stackoverflow.com/questions/27940973/html5-data-attributes-how-to-modify-array-of-data-attached-to-dom-element
* http://stackoverflow.com/questions/28443145/ruby-json-multi-word-strings-rendered-incorrectly-in-html

