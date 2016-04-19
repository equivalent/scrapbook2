
```
=          # reindent, highligted text
J          # join highlited lines a\n b\n c\  => abc

# buffers


to change yank to buffer `a` in normal mod do

```
"ay
"ap
```

... so the quote `"` is the buffer changer

default buffer is `"`  so `""y`

While you are in insert mode you can press `ctrl + r`(paste mode) and name of buffer
(`a`) and you will paste the content of a buffer

there is also a "black hole" buffer `_` that will lose the information
inmidiately

# scrolling two splits at the same time

go to first split and `:set scrollbind`  go tho other and do `:set scrollbind`
now you are scrolling both with j,k

`:set noscrollbind` to disable


# increese number 

hover ower number in normal mod and press `ctrl-a` to increase number or `ctrl-x` to
decrease

# Tabs vim 

http://vim.wikia.com/wiki/Using_tab_pages

```
gt            go to next tab  # equivalent to tabnext
gT            go to previous tab # equivalent to tabprevious
{i}gt         go to tab in position i
:tabe
:tabfirst
:tablast
:tabclose
```


# Tabularize

```
:'<,'>Tabularize /=
:'<,'>Tabularize /:\zs
```

http://vimcasts.org/episodes/aligning-text-with-tabular-vim/


# resize split window

http://vim.wikia.com/wiki/Resize_splits_more_quickly

vs

```
:vertical resize +5
:vertical resize -5

Ctrl-w <    > 
```

# CTags in rails

```sh
gem install ripper-tags

ripper-tags -R --exclude=tmp # will index all .rb files
```

note janus vim has C-Tags by default

# Basic usage 

## Change file type

...or tell vim to use other language code syntax

```
:set filetype=markdown
:set filetype=ruby
```

## Normal mode

Copy Paste

```
y         # copy
P         # paste in fron of word
p         # paste on position wher you are

```

movement

```
B b h <>l w W									# word movement
0 ^ gE ge <> e E $						        # home 
g0 g^ <gm> g$									# whole line home
42gg alebo 42G								    # go to line 42

{   }										    # start and end of paragraf
(   )											# start and end of sentence
```

scroll

```
zt zz zb    									#scroll top midle bottom
H  M  L
ctrl+e   ctrl+y                                 #clasik scrolling
```

Replace

```
R                                               #replace mode. Replace everything you type
                                                # Backspace will rollback changes 
```

## Visual mode

By visual mode some people refers to "highlite" or visual block mode (visually highlight 
text). The key part is that you can call commands while text is selected this way.

```
u                                               # Lovercase
U                                               # Upcase text
r                                               # replace selected with...; also check for `R`
```


# Advanced examples

### Edit multiple lines on certain position

There is command `Ctrl+q` that works similar as  as `v` (visual select bolck mode). By pressing it you can navigate
through out of the text (`jj`, `kk`, `hh`, `ll`) selecting multiple lines several cels of text.

![Select multiple lines in position with Vim][1]

**Add text on multiple lines**

* After selecting text this way you can pres `I`
* insert text
* press `escape`

**Remove text on multiple lines**

* After selecting text this way you can pres `d`



sources:

* http://vim.wikia.com/wiki/Inserting_text_in_multiple_lines

published 18.09.2013




### Sort words in vim

visual select block of lines and trigger 

    call setline('.', join(sort(split(getline('.'), ' ')), " "))

example

    a o e b x p
    :'<,'>call setline('.', join(sort(split(getline('.'), ' ')), " "))
    a b e o p x
    
sources:

*http://stackoverflow.com/questions/1327978/sorting-words-not-lines-in-vim

published: 18.09.2013




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

published: 18.09.2013





### Rename ruby class name to method name

...or how to change capitalized constant strings to underscore strings

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


### Get rid of ^M in code

    :%s/^M//g

































[1]: https://raw.github.com/equivalent/scrapbook2/master/assets/images/2013/vim_scrap_replace-multiple-lines-on-position.png
