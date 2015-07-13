
source: ruby tapas 322 benchmarking

some examples https://gist.github.com/equivalent/3c9a4c9d07fff79062a3

```ruby
require 'benchmark'

result = Benchmark.measure do
  10_000.times do 
    str = 'Supercalifragisilticexpialidocious'
    str.reverse!
    File.write('/tmp/word.txt', str)
  end
end

result.real   # the actual time that passed (wall clock time)
              # this value can be affected by other stuff the comupter
              # is doing
#=> 0.754803923

result.utime  # time spent in user land (ruby virtual machine) 
              # (not affected by other stuff comutper is doing)
#=> 0.14

result.stime  # time spent in operating kernel (file write)
              # for execution of this piece of code (not affected by
              # other stuff comutper is doing)
#=> 0.34

result.total  # utime + stime 
#=> 0.48000000000000004 
```

```ruby
require 'benchmark'

class Handler
  def handle_stepintime
  end
end

handler = Handler.new
n       = 1_000_000

Benchmark.bmbm(allign_number_of_chars = 20) do |reporter_object|
  event = :stepintime

  reporter_object.report('case dispatch') do
    n.times do
      case event
      when :stepintime then handler.handle_stepintime
      end
    end
  end

  reporter_object.report('dynamic_dispatch') do
    n.times do
      handler.send("handle_#{event}")
    end
  end
end

#                            user     system      total        real
# case dispatch          0.120000   0.000000   0.120000 (  0.113965)
# dynamic_dispatch       0.500000   0.000000   0.500000 (  0.503731)
```

when virtual machine isn't wormed up it will affect the results (so
second may be faster than first just because it's lunched as second)

we can preworm VM with `bmbm` that will lunch it twice so the second
result is more accuret

```ruby


Benchmark.bmbm(allign_number_of_chars = 20) do |reporter_object|
  event = :stepintime

  reporter_object.report('case dispatch') do
    n.times do
      case event
      when :stepintime then handler.handle_stepintime
      end
    end
  end

  reporter_object.report('dynamic_dispatch') do
    n.times do
      handler.send("handle_#{event}")
    end
  end
end



# Rehearsal --------------------------------------------------------
# case dispatch          0.110000   0.000000   0.110000 (  0.114776)
# dynamic_dispatch       0.500000   0.000000   0.500000 (  0.500196)
# ----------------------------------------------- total: 0.610000sec
#
#                          user     system      total        real
# case dispatch          0.120000   0.000000   0.120000 (  0.112768)
# dynamic_dispatch       0.510000   0.000000   0.510000 (  0.507379)
```

