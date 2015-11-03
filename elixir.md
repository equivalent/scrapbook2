```
foo = 1 # 1
1 = foo # 1
2 = foo # ** (MatchError) no match of right hand side value: 1
bar     # ** (CompileError) iex:3: undefined function bar/0
{:foo, bar} = {:foo, 3}   # {:foo, 3}
{_, baz} = {1, 2}
baz # 2 
[a, 2] = [1, 2]
[a, 2] = [3, 2] # Here, "a" gets re-bound
[^a, 2] = [4, 2] # MatchError




false == :false
nil == :nil   # atoms are like symbols in Ruby 

```


##  Keyword list (Ruby hash like syntax)

```
[author: "Josh Adams", title: "Basic Elixir"] == [{:author, "Josh
Adams"}, {:title, "Basic Elixir"}]
```


## regular expression

```
Regex.replace %r/[aeiou]/, "Beginning Elixir", "z" # "Bzgznnzng Elzxzr"
```


## functions with `fn`

```ex
a = fn (var, var2) ->
  var + var2
end
```

```
# > Function<12.54118792/2 in :erl_eval.expr/5>
a.(5, 3)
# > 8

```

## anonymaus functions

```
b = &(&1 + &2)

b.(4)
# >  ** (BadArityError) &:erlang.+/2 with arity 2 called with 1 argument (1)

b.(2, 4)
# > 6
```

## modules

```ex
# /tmp/my_awesome.ex

defmodule MyAwesome do
  def do_stuff(a, b) do
    a + b
  end

  def fall_velocity(distance) do
    :math.sqrt(2 *  9.8 * distance)
  end

  # one liner methods
  def do_shit_publicly(x), do: do_shit(x + 2)

  # private method definition 
  defp do_shit(x) do
    x + 4
  end
end

MyAwesome.do_stuff(MyAwesome.fall_velocity(5), 11)
# > 20.899494936611667

MyAwesome.do_shit(11)
# > (UndefinedFunctionError) undefined function: MyAwesome.do_shit/1

MyAwesome.do_shit_publicly(5)
# > 11
```

# compiling

```ex
c("/tmp/drop.ex")  # compile file and use it imidiately
MyAwesome.do_shit_publicly(5)
# > 11
```

# from module to free float function

```ex

stuff = &MyAwesome.do_stuff/2
stuff.(2, 2)
# > 4

well_shit = &MyAwesome.do_shit_publicly/1
well_shit.(2)
# > 8

```

You can also do this within code in a module. If you’re referring to
code in the same
module, you can leave off the module name preface. In this case, that
would mean leaving
off Drop. and just using `&(do_shit_publicly/1)`.


# pipe forward

defmodule CombinedStuff do
  def stuff do
    MyStuff.do_stuff(OtherStuff.other(5))
  end

  def stuff_different_way do
    OtherStuff.other(5) |> MyStuff.do_stuff
  end
end

The  pipe  operator  only  passes  one  result  into  the  next
function  as  its first  parameter.  If  you  need  to  use  a  function
that  takes  multiple  parameters,  just  specify  the  additional
parameters  as  if  the  first  didn’t have  to  be  there.

# exaple of knowlednge sofar

```
defmodule Bla do
  def blabla(arg) do
    arg * 8
  end
end

defmodule Foo do
  def foo(arg) do
    arg + 3
  end
end

defmodule Bar do
  def bar(arg) do
    arg + 13
  end
end

Foo.foo(6) |> Bla.blabla |> Bar.bar
#> 85

defmodule Combined do
  import Bar
  import Foo
  import :math

  def call do
    bar(Bla.blabla(foo(6)))
  end


  def call_pipe_forward do
    foo(6) |> Bla.blabla |> bar
  end

  def x
    sqrt(5)
  end
end

Combined.call
#> 85
Combined.call_pipe_forward
#> 85
Combined.x

```

