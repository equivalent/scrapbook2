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
