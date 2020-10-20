in order to jQuery trigger RJS format.js response do `dataType: 'script'`

```
$.ajax({
  url: $("form#new_picture").attr("action"),
  type: "POST",
  data: formdata,
  processData: false,
  contentType: false,
  dataType: 'script'
});
```


o


```
$('#company-sections').append("<div class=\"col s12 m6 l4\"><%=escape_javascript(render(:partial => "sections/card", :collection =>@results)).html_safe %></div>");

```
