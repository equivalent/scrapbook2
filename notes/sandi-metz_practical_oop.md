# Sandi Metz - practical object oriented programing NOTES

NOTE: I'm writing this notes on a train via smartphone, there are lot of
spelling mistakes and typos

## arguments

If you can, initialize your objects with hash rather than fix order
arguments. If you cannot (class of external framework) you can wrap it with
factory.

wrap the interface to protect yourself from changes:

```ruby
module GearWrapper
  def self.gear(args)
    SomeFramework::Gear.new(args[:chainring], args[:cog], args[:wheel])
  end
end
```

# Dependencies

Depend on classes that are less likely to change (framework will not
change that often as your code, ruby core even less)

# Interfaces

Object design is not about classes but about messages passed between
them.

Focusing too much on classes as domain objects will end up placing
behaviour in them that is not necessarily their responsibility.

You don't have messages because you have classes, but you have classes
because you have messages that you need to be send to them.

Sequence diagrams (uml) let you explore what possibilities of classes
you have to send messages too



