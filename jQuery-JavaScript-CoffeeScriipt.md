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


### Remove a value from an array

```coffee
  array = ['keep', 'add-new']
  array = (x for x in array when x != 'keep')
  array   # => ['add-new']
```

http://stackoverflow.com/questions/8205710/remove-a-value-from-an-array-in-coffeescript

### 

```coffee
# data loaded through ajax [Object { draft=true, id=49}, Object { draft=false, id=44}]

hasAnyDrafts = (data) ->
  (x for x in data when x['draft']).length > 0


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
