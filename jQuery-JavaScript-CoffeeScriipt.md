
### select elements within of element

```html
<div class="foo">
  <span>foo</span>
</div>

<span>foo</span>
```

```js
$('span')               # all spans

$('.div span')          # span inside `.foo` div 

var my_div = $('.foo')
$('span', my_div)       # span inside `.foo` div
```
