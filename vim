


:sort u                      #remove duplicates




## Substitude usefull examples

### Rename ruby class name to method name

```vim
:s/[A-Z]/_\l\0/g
```

```
#before    
StaticDocumentForm

#after
_static_document_form
```

I'm to lazy to figure out the leading underscore :)

