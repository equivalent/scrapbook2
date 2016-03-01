### check last 5 checkboxes

```
$('tr input').slice(-5).prop('checked', 'true')
```

### Escaping XSS

```js
$('.my-item').text('<script>alert(0)</script> aaa')  // will escape 
$('.my-item').html('<script>alert(0)</script> aaa')  // will not escape  XSS unsafe


    info = $('.my-item')
    info.text('')
    info.append("<i class='fa fa-file-o'></i> ")
    info.append(document.createTextNode($('input').val())) // createTextNode this will escape
```

http://api.jquery.com/text/


### Rails UJS callbacks

https://github.com/rails/jquery-ujs/wiki/ajax

```coffee
  $("a[data-prompt]").on "ajax:error", (handler, data, status, xhr) ->
    alert 'Error occurred while sending your message !!!'
```

### passing additional data params in UJS

it seems that Rails UJS lib is using `data-params` for passing additional params when doing ajax request

```haml
= link_to '/applications/123', method: 'patch', remote: true, data: { params: { :'application[name]' => 'bar' }, confirm: 'true' } do 
  something

```

### rails UJS change js to json

all you have to do is to use `data-type json` in link

```haml
= link_to 'foo', root_path, data: {type:json, prompt: ...}
```


### on Bindings

good article [difference between .bind() .live() .delegate()](http://www.alfajango.com/blog/the-difference-between-jquerys-bind-live-and-delegate/)

overal bindings when page is loaded

```coffee
$(document).ready -> 
  #...

#is equivalent of 

$(document).on 'ready', ->  


# so for when document is ready or when turbolinks.js loads the page

$(document).on 'ready page:load', ->
  $('#fetch_custom_form').change ->
    $(this).submit()
    

# or even cleaner

ready = ->
  alert('aa')
$(document).ready(ready)
$(document).on('page:load', ready)


```

own bindings

```coffee
class Foo
  load: ->
    thisI = this
    $.ajax "/application",
      success: (data) ->
        $('#foo').html(data)
        $(document).trigger('fooLoaded')

$(document).on 'ready fooLoaded', ->
  foo = new Foo
  foo.load()
```


### jQuery $.when().then() and gladual delayed recursion

...or how to load multiple ajax request gradually (one after one)

```coffee

class LoadStuff

  loadAll: ->
    names = ['one', 'two', 'three']
    this.recursionLoad(names.pop(), names)
  
  recursionLoad: (one, many) ->
    self = this
    if one
      $.when(self.loadOne(one)).then ->
        self.recursion(many.pop(), many)
        
  loadOne: (registryName) ->
    $.ajax '/foo/bar',
      type: 'get'
      dataType: 'json'
      data:
        name: registryName
      error:
        #...
      success: (data) ->
        #...
        
        
l = new LoadStuff
l.loadAll()   # will trigger ajax calls one after one 
```


### Make class accessable from Firebug Console

```coffee
# app/assets/javascripts/my_script.coffee

class FooBar
  car: ->
    alert 'aaa'
    
window.FooBar = FooBar
```

and in firebug console you can now do:

```
foo = new FooBar
foo.car()
```

### Select elements within of element

```html
<div class="foo">
  <span>foo</span>
</div>

<span>foo</span>
```

```js
$('span')               // all spans

$('.div span')          // span inside `.foo` div 

var my_div = $('.foo')
$('span', my_div)       // span inside `.foo` div
```

### convert value to boolean in JavaScript

```js
!!4       // true
!!null    // false
!!false   // false
!!'aaa'   // true
```

### Remove a value from an array

```coffee
  array = ['keep', 'add-new']
  array = (x for x in array when x != 'keep')
  array   # => ['add-new']
```

http://stackoverflow.com/questions/8205710/remove-a-value-from-an-array-in-coffeescript

### Check if JSON has a element in CoffeeScript

```coffee
# data loaded through ajax [Object { draft=true, id=49}, Object { draft=false, id=44}]

hasAnyDrafts = (data) ->
  (x for x in data when x['draft']).length > 0


```

### jQuery Ajax example + load Handlebars template

```coffee
$.ajax '/documents/latest',
  type: 'get'
  dataType: 'json'
  data:
    document_name_id: 11
    owner_type: 'Client'
    owner_ids:  22
  success: (data) ->
    $('#existing_documents').html(HandlebarsTemplates['documents/latest_docs'](data))
  error: ->
    $('#existing_document_versions').html('Loading...')
    
```

### jQuery example how  to properly watch if chekbox was chceked and if so check other checkboxes

coffescript:

    $('input:checkbox[data-toggle-checkboxes]').change ->
      target = $(@).data('target')
      boxes  = $(@).closest('form').find('input:checkbox[name="' + target + '"]').prop('checked', $(@).is(':checked'))

html:

    <form>
      <input type="checkbox" value="1" name="toggle" id="toggle" data-toggle-checkboxes="true" data-target="ids[]">

      <input type="checkbox" value="4" name="ids[]" id="ids_">
      <input type="checkbox" value="5" name="ids[]" id="ids_">
      <input type="checkbox" value="6" name="ids[]" id="ids_">
    </form>


jQuery: 1.9
Rails : 3.2
date: 2013-04-11
credits: Delwynd, with my small changes

### jQuery is option

    $('input#global').is(':checkbox')
    $('input#global').is(':checked')
    $('input#global').is(':disabled')


### jQuery fetching data attribute values

let say you have

```html
<form action="/foo" data-draft-id="34"></form>
```

you can fetch data with:

```coffee
$('form').data('draft-id')

$('form').data('draftId')   //more valid js syntax
````




# Handlebars helper isSelected()

 handlebars helper for determine which option was selected in select box

helper

    # a/a/javascript/app.coffee
    Handlebars.registerHelper 'isSelected', (id, select_element) ->
      return 'selected="selected"' if ( $(select_element).val().toString() == id.toString())

template

    #a/a/javascripts/templates/documnet.hbs
    <option value=""></option>
    {{#each this}}
      <option value="{{id}}" {{isSelected id "select#document_document_name_id"}}>{{name}}</option>
    {{/each}}

note: I tried this with pure Handlebars not as part of Ember.js
rails 3.2.12
date: 2013-03-22


# Get url variables

    #app/assets/javascript/app.coffee
    $(document).ready ->
      window.getQueryVariable = (variable) ->
        query = window.location.search.substring(1)
        vars = query.split("&")
        i = 0

        while i < vars.length
          pair = vars[i].split("=")
          return pair[1]  if pair[0] is variable
          i++
        false

usage:

    if getQueryVariable('document_name_id')  == '14'

from http://css-tricks.com/snippets/javascript/get-url-variables/
keys: get url variables 
