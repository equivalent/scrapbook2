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

## mix

```
mix new my_project
cd my_project

vim lib/modules_example.ex

iex lib/my_project.ex
# iex will compile, therefore module is avalible
MyProject.publish('foo')

# to compile to .beam file use `elixirc lib/my_project.ex`, 
# this will create .beam file in dir. Next time you lunch plain `iex`
# with no args from this dir you will have this mobule availible 
iex
MyProject.publish('foo')

```


to install dependency 

```
vim my_project/mix.exs  # alter the `dep` with tupple { :blabla, github: 'bla/blabla' }
mix deps.get 
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




# BOOK notes Elixir by D.T. notes

`.ex` are files ment to be compiled to binary `.exs` are source files
thta should not end in binaary (tests e.g.)

`iex` helpers:
* h
  * h IO
  * h IO.puts

```iex
iex(1)> a = [1,2,3]
[1, 2, 3]
iex(2)> a = 4
4
iex(3)> a
4
iex(4)> 4 = a
4
iex(5)> [a,b] = [1,2,3]
** (MatchError) no match of right hand side value: [1, 2, 3]
    
iex(5)> a = [[1,2,3]]
[[1, 2, 3]]
iex(6)> [a] = [[1,2,3]]
[[1, 2, 3]]
iex(7)> a
[1, 2, 3]
iex(8)> [[a]] = [[1,2,3]]
** (MatchError) no match of right hand side value: [[1, 2, 3]]
    
iex(8)> [a,b,c]=[1,2,[1,2,3]]
[1, 2, [1, 2, 3]]
```

```iex
iex(1)> [a,b,c]=[1,2,3]
[1, 2, 3]
iex(2)> [a,b,a]=[1,1,2]
** (MatchError) no match of right hand side value: [1, 1, 2]
    
iex(2)> [a,b,a]=[1,2,1]
```

```iex
iex(1)> a = 2
2
iex(2)> [a,b,c]=[1,2,3] 
[1, 2, 3]
iex(3)> [a,b,a]=[1,1,2]
** (MatchError) no match of right hand side value: [1, 1, 2]
    
iex(3)> a = 1
1
iex(4)> ^a=2
** (MatchError) no match of right hand side value: 2
    
iex(4)> ^a=1
1
iex(5)> ^a=2 -a
1
iex(6)>  
```

```iex
result = with {:ok, file} =  File.open("/etc/passwd"),
               content    = IO.read(file, :all),
               :ok        = File.close(file),
               [_, uid, gid] = Regex.run(~r/_lp:.*?:(\d+):(\d+)/, content) do
                 "Group  #{gid}, user #{uid}"
               end
```

```iex
abc = fn -> IO.puts "hello" end
abc.()

abcd = fn a, b -> a + b end
abcd.(3,4)

iex(15)> x = fn
...(15)>   {2,2} -> " some twos"
...(15)>   {:ok, _} -> "something ok"
...(15)> end
iex(17)> x.({2,2})
" some twos"
iex(18)> x.({:ok,2})
"something ok"


x = fn
  {2,2} -> ( fn -> "two" end)
  {:ok, _} -> ( fn -> "carl" end)
end

IO.puts x.({2,2}).()
IO.puts x.({:ok, 'carl'}).()


xx  = fn
  x -> (fn y -> "#{y} #{x}" end)
end
IO.puts xx.("carl").("marks")
#=> "marks carl"
```

```iex
defmodule Greeter do
  def for(name, greeting) do
    fn
      (^name) -> "#{greeting} #{name}"
      (_) -> "I don't know you"
    end
  end
end
mr_valim = Greeter.for("tomi", "Oi!")
IO.puts mr_valim.("tomi")
IO.puts mr_valim.("dave")
# => Oi! tomi
# => I don't know you
```

```iex
xx = fn
  {:ok, file} -> IO.read(file, :all)
  {_, error}  -> "Error #{error} #{:file.format_error(error)}"
end

IO.puts xx.(File.open("/etc/passwd"))
IO.puts xx.(File.open("/etc/passwdddd"))

# alternative

with {:ok, abc} = File.read("/etc/passwd") do
  IO.puts abc
end
```


```iex
```
