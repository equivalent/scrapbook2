# ruby macros

as presented in ruby tapas episode 27 & 28

Lighter version: 

```ruby
class Dradis
  include Eventful

  event :new_contact

  attr_reader :contact_count

  def initialize
    @contact_count = 0
  end

  def new_contact(*)
    @contact_count += 1
    super
  end
end

module Eventful
  def self.included(other)
    other.extend(Macros)
  end

  def add_listener(listener)
    (@listeners ||= []) << listener
  end

  def notify_listeners(event, *args)
    (@listeners || []).each do |listener|
      listener.public_send("on_#{event}", *args)
    end
  end

  module Macros
    def event(name)
      mod = Module.new
      mod.module_eval(%Q{
        def #{name}(*args)
          notify_listeners(:#{name}, *args)
        end
      })
      include mod
    end
  end
end
class Dradis
  include Eventful

  event :new_contact

  attr_reader :contact_count

  def initialize
    @contact_count = 0
  end

  def new_contact(*)
    @contact_count += 1
    super
  end
end
class ConsoleListener
  def on_new_contact(direction, range)
    puts "DRADIS contact! #{range} kilometers, bearing #{direction}"
  end
end

dradis = Dradis.new
dradis.add_listener(ConsoleListener.new)
dradis.new_contact(120, 23000)
dradis.new_contact(250, 42000)
puts "Contact count: #{dradis.contact_count}"
```

More compredensive version:

```ruby
module Eventful
  def self.included(other)
    other.extend(Macros)
  end

  def add_listener(listener)
    (@listeners ||= []) << listener
  end

  def notify_listeners(event, *args)
    (@listeners || []).each do |listener|
      listener.public_send("on_#{event}", *args)
    end
  end

  module Macros
    def event(name)
      mod = if const_defined?(:Events, false)
              const_get(:Events)
            else
              new_mod = Module.new do
                def self.to_s
                  "Events(#{instance_methods(false).join(', ')})"
                end
              end
              const_set(:Events, new_mod)
            end
      mod.module_eval(%Q{
        def #{name}(*args)
          notify_listeners(:#{name}, *args)
        end
      })
      include mod
    end
  end
end
class Dradis
  include Eventful

  event :new_contact
  event :radiation_warning
  event :tigh_is_drunk_again
end
  
Dradis::Events.instance_methods(false).each do |event_trigger|
  puts event_trigger
end
```
