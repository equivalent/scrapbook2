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




Static type languages: requires to declare type of variable all the time
Dynamic type lang. : any variable can be any type at any pont
Metaprogramming : code that writes code


Every time you create a class, declare its interfaces. Methods in the  public interface should • Be explicitly identified as such • Be more about  what than how • Have names that, insofar as you can anticipate, will not change • Take a hash as an options parameter

Tests serve as documentation therefor do not test private methods or, if you must, segregate those tests from the tests of public methods.


Demeter 
* remove trainwracks
* instance methods shouldn't chain methods of different types/ classes its not aware of(its ok to chain string its not ok to chain bike.cog.wheel.rotate.... code knows not only  what it wants (to rotate) but  how to navigate through a bunch of intermediate objects to reach the desired behavior)
* to prevent breaking app delegate methos class don't own


Duck typing
* purpose is to provide well defined public interfaces not bound to any class
* if class walks like a duck quacks like a duck it is a duck
* trust ducktype methods that they know what they should do
* if something is has method `prepare_trip` its Preparer = its ok to create virtual types in benefit of documenting code. Preparers share interface not implementation (each do its work own way) Virtual type is defined on what they do not who they are.
* is_a?   kind_of?  Class based case statements : Is good indication of ducktype should be introduced, HOWEVER if code is checking type of more stable classes (Hash, Array) it may be better not to monkey patch these classes and therefore not introduce ducktype
* 


* Technique of defining a basic structure in the superclass and sending messages to acquire subclass-specific contributions is known as the  template method pattern.
* Any class that uses the template method pattern must supply an implementation for every message it sends, even if the only reasonable implementation in the sending class looks like this: 
1 class Bicycle 2 #... 3 def default_tire_size 4 raise  NotImplementedError 5 end 6 end

Or

class Bicycle 2 #... 3 def default_tire_size 4 raise  NotImplementedError, 5 6 end 7 end

* Always document template method requirements by implementing matching methods that raise useful errors. 


Inheritance ans modules

* Modules in class are called in revers order
- last module will be called first

* liskov substitution principle- honour contract - respect superclass.. Respect what superclass is doing don't rise  NotImplementError - subtypes must be interchangeable with their supertype

* prefer shalow inheritance as in deep inheritance programer usually understand top and bottom only => more errors. Shallow narow inheritance is easy to understand




class Parts 3 extend  Forwardable 4 5 6 def_delegators  :@parts, :size, :each include  Enumerable 7 def initialize(parts) 8 @parts = parts 9 end 10 11 12 13 def spares select {|part| part.needs_spare} end 14 end

segregate those tests from the tests of public methods.


Demeter 
* remove trainwracks
* instance methods shouldn't chain methods of different types/ classes its not aware of(its ok to chain string its not ok to chain bike.cog.wheel.rotate.... code knows not only  what it wants (to rotate) but  how to navigate through a bunch of intermediate objects to reach the desired behavior)
* to prevent breaking app delegate methos class don't own


Duck typing
* purpose is to provide well defined public interfaces not bound to any class
* if class walks like a duck quacks like a duck it is a duck
* trust ducktype methods that they know what they should do
* if something is has method `prepare_trip` its Preparer = its ok to create virtual types in benefit of documenting code. Preparers share interface not implementation (each do its work own way) Virtual type is defined on what they do not who they are.
* is_a?   kind_of?  Class based case statements : Is good indication of ducktype should be introduced, HOWEVER if code is checking type of more stable classes (Hash, Array) it may be better not to monkey patch these classes and therefore not introduce ducktype
* 


* Technique of defining a basic structure in the superclass and sending messages to acquire subclass-specific contributions is known as the  template method pattern.
* Any class that uses the template method pattern must supply an implementation for every message it sends, even if the only reasonable implementation in the sending class looks like this: 
1 class Bicycle 2 #... 3 def default_tire_size 4 raise  NotImplementedError 5 end 6 end

Or

class Bicycle 2 #... 3 def default_tire_size 4 raise  NotImplementedError, 5 6 end 7 end

* Always document template method requirements by implementing matching methods that raise useful errors. 


Inheritance ans modules

* Modules in class are called in revers order
- last module will be called first

* liskov substitution principle- honour contract - respect superclass.. Respect what superclass is doing don't rise  NotImplementError - subtypes must be interchangeable with their supertype

* prefer shalow inheritance as in deep inheritance programer usually understand top and bottom only => more errors. Shallow narow inheritance is easy to understand




class Parts 3 extend  Forwardable 4 5 6 def_delegators  :@parts, :size, :each include  Enumerable 7 def initialize(parts) 8 @parts = parts 9 end 10 11 12 13 def spares select {|part| part.needs_spare} end 14 end


* Factory - object that creats objects


* In most cases when you see  composition it will indicate nothing more than this general  has-a relationship between two objects. However, as formally defined it means something a bit more specific; it indicates a  has-a relationship where the contained object has no life independent of its container.  
* Aggregation is exactly like composition except that the contained object has an independent life. 


* The general rule is that, faced with a problem that composition can solve, you should be biased towards doing so. If you cannot explicitly defend inheritance as a better solution, use composition. Composition contains far fewer built-in dependencies than inheritance; it is very often the best choice. Inheritance  is a better solution when its use provides high rewards for low risk. This section examines the costs and benefits of inheritance versus composition and provides guidelines for choosing the best relationship.
* inheritance : Behavior is dispersed among objects and these objects are organized into class relationships such that automatic delegation of messages invokes the correct behavior
* composition, the relationship between objects is not codified in the class hierarchy; instead objects stand alone and as a result must explicitly know about and delegate messages to one another. Composition allows objects to have structural independence, but at the cost of explicit message delegation.

* ducktype needs to honor contract. Bicycle is a schedulable but mainly it's a bike. Ducktepes are better understood from point of schedulable. What bicycle needs to implement to became a schedulable not other way around 

* unused interface method - delete or mare it private it otherwise you need to write a test as you are exposing it for other dvelopers
* Factory - object that creats objects


* In most cases when you see  composition it will indicate nothing more than this general  has-a relationship between two objects. However, as formally defined it means something a bit more specific; it indicates a  has-a relationship where the contained object has no life independent of its container.  
* Aggregation is exactly like composition except that the contained object has an independent life. 


* The general rule is that, faced with a problem that composition can solve, you should be biased towards doing so. If you cannot explicitly defend inheritance as a better solution, use composition. Composition contains far fewer built-in dependencies than inheritance; it is very often the best choice. Inheritance  is a better solution when its use provides high rewards for low risk. This section examines the costs and benefits of inheritance versus composition and provides guidelines for choosing the best relationship.
* inheritance : Behavior is dispersed among objects and these objects are organized into class relationships such that automatic delegation of messages invokes the correct behavior
* composition, the relationship between objects is not codified in the class hierarchy; instead objects stand alone and as a result must explicitly know about and delegate messages to one another. Composition allows objects to have structural independence, but at the cost of explicit message delegation.

* ducktype needs to honor contract. Bicycle is a schedulable but mainly it's a bike. Ducktepes are better understood from point of schedulable. What bicycle needs to implement to became a schedulable not other way around 

* unused interface method - delete or mare it private it otherwise you need to write a test as you are exposing it for other dvelopers



