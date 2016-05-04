

# one or other in list

```
(?:tom|jon)
```


# when is  Regex slow

```ruby
string = 'aaaaazzzzzaaaaazaaaa'

# greedy (lazy) quatifier
\A(a.*)z
# =>  'aaaaazzzzzaaaaa'

# non-greedy quantifier
\A(a.*?)z
# => aaaa

```

this both are looping from **end** of the string till they find the point to stop.
The difference is that greedy will stop at first occurence, while non-greedy is looping
till he's sure that no other occurence exist

even wors is to do `(.*)?` which is like loop within a loop 

so imagine now 10GB log file how would that screw your computer

Faster solution is to use negative, so search everything not matching and than actually match something 

```
# www.fooooo.com
[^.]*\.(\w*)

```

Special thanx to [tom](https://github.com/tom-lord) for pointing this out

# watch out for hyphen

``` 
[a-z]  # a till z in ascii table
[a_-]  # a or underscore or minus
[a_-*] # a or (_ till * in ascii table)
```
