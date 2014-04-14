# bootstrap sticky footer

```haml
%html
  %body
     Some  body stuff
    
    %footer
      footer content
```

```sass
$footer-height: 110px

html
  position: relative
  min-height: 100%

body
  margin-bottom: $footer-height

body > footer
  position: absolute
  bottom: 0
  width: 100%
  height: $footer-height
```

* http://getbootstrap.com/examples/sticky-footer-navbar/
* http://stackoverflow.com/questions/17966140/twitter-bootstrap-3-sticky-footer

# bootstrap center

bootstrap 3 actually provide several classes to centralize

* [.conter-block](http://getbootstrap.com/css/#helper-classes-floats)  centers with margin left/right auto

`<div class="center-block">...</div>` 

* .text-center  centers with `text-align`

`<div class="text-center">...</div>` 


example: http://jsfiddle.net/mynameiswilson/eYNMu/


keywords: how to center bootstrap pagination
