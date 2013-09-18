

### sort words in vim

visual select block of lines and trigger 

    call setline('.', join(sort(split(getline('.'), ' ')), " "))

example

    a o e b x p
    :'<,'>call setline('.', join(sort(split(getline('.'), ' ')), " "))
    a b e o p x
    
sources:

*http://stackoverflow.com/questions/1327978/sorting-words-not-lines-in-vim

published: 19.09.2013




### remove duplicate lines



    :sort u

example:

```
aa
bb
cc
aa
dd

:sort u

aa
bb
cc
dd
```

sources: 

* http://vim.wikia.com/wiki/Uniq_-_Removing_duplicate_lines

published: 19.09.2013


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

