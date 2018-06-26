

```
$('#company-sections').append("<div class=\"col s12 m6 l4\"><%=escape_javascript(render(:partial => "sections/card", :collection =>@results)).html_safe %></div>");

```
