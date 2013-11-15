
# parent/root context

there is no possibillty to access root context of template once you change the context
with looping (e.g. each) [more info](https://github.com/wycats/handlebars.js/issues/392) .
However there is a posibillity to access previous context with '../' 



```coffee
body = HandlebarsTemplates['contents/present_content']({
  view:{
    registryName: 'foo',
    data: {items: {x: 'x'}}
    }
  })
```


```hbs
<table class="table">
  <tbody>

  {{#each view.data.items}}
    <tr>
      <td>{{@key}}</td>
      <td>
        Hello from {{../view.registryName}}
      </td>
    </tr>
  {{/each}}
  </tbody>
</table>
```

check http://handlebarsjs.com/#paths  for more info
