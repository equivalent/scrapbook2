# Moores Law and simple solution



Transistor is a semiconductor device that serves as a switch
in electrotechnics. This is done by controlling flow of electricity by opening a socalled  "gate". 

now this represents on / off, true /false, 0/1. We call this infromation 
a "bit"

The speed in which you open and close the 
gate is called "Frequency" or 'clock speed'


Put eight transistors (or bits) to gether and you are able to do
"Byte operations" and construct letters.

Now put bilion transistors together and you have a computer processor
(central processing unit)
Think about processor as a brain inside comupter. The bilion of transistors
connect to eachother like neurons in human branis.

Now in order to place so many transistors on a processor chip manufacturers
use element silicon. Now this is not like silicon found in Sand but 
really really pure silicon like 99.99999 pure silicon


That's it for basic theory, here comes the punch line


in 1965 Gordon E moore published an article in which he predicted that
"number of transistors that can fit on a single chip will double 
every year"

10 years later he was cofounder of chip company Intel. Later executive
of intel David House restated this clame that "performance of processors
would doubel every 18 moths"

now this prophesy went on for serveral decades and became knows as
Moorse Law. So it's not a law like gravity but technology trend
prediction.


Now since then everyone used different factor to show moores law.
Some were using clock speed per year, some number of transistors per year, some overal performance per year.

The thing is that some of the data is poninting to the fact that we 
are not getting faster and therefore "Moores Law ending"

No mather what data we use for this conclusion the fact is that
we are getting close to the peak of phisical capability of Silicon.

We are nearly at atom level and if manufacturers make the transistor
gates even smaller then we would be dealing with quantum physics issues
( electron may jump)  therefore our transistors wont be able to 
guarantee 0 or 1. 

This may be a big deal if you want to transfer
money via internet banking.  Maybe it will arrive to correct person
maybe they wont.

Another issue is heat. If we increase the clock speed beyound
current limints to push the
processing capabilities our computers may melt.


Now reason why I'm making this talk is that recently I was watchinch
quite interesting video on this topic that was trying to cover the
solution. And it I presenting new technologies like 
* "graphene processors"
* "molecular transistors" (so basically entire trasistor is one molecule
* "photon tranisistors" ( where beam of light is controlling the gate)
* "protein processors"
* "DNA based computers" 





notes from https://www.youtube.com/watch?v=UTVEVvfGOIw&t=4s

* in 1965 Gordon E Moore wrote an article where he predicted the number
  of transistors that can fit on a single chip will double evry year, 10
years later he was one of co-founders of intel. He predicted this will
happen every 2 years So technically the performance of processor would double every
18 months


* reasons for slowdown 
  * heat => more processing more heat generated
  * size => we are nearly at atom level and if manufacturers make the
    gates even smaller then we would be dealing with quantom phisics
issues  (quantom tunneling). =>basically for transistor to function it
needs to be totaly on or totally off.


* Graphin processors
* molecular transistors (single molecule that controls the gate) 
* photon transistors
  * transistor that uses beam of light to do the on/off switch instead of electron
* protein processor
* dna computers 
  * ther is a posibility to store pentabytes of data in DNA buildingblocks
  * there are some experiments with dna gates

* quantom comupters




hyperthreading 

https://www.youtube.com/watch?v=wnS50lJicXc


There are two components when we talk about computers limitation: Hardware and
Software. Hardware being the computing processors,  memory, disk space, and so on
And then there is Software. These are programs we are executing. You know our
Microsoft Excel, Minecraft or everyone's favorit Tax software.

You see the reason why Moore's law is a big deal is because most of our
software can run only on one processor core.

But at this point of human civilization you can have and you probably already own multiple multi core
processor device. Latest smartphones like iPhone or Google Pixel have like 4 to 8
cores, modern laptops have 2 or 4 cores, some graphic cards have like 512 cores,
even most popular Intel chips i3, i5, i7 chips have 2
physical cores. Well Intel is branding them as chips that can do
"Hyperthread" to 4 cores but in reality they have 2 physical cores that
can act as extra virtual cores. It's a hack that I'll talk about later.


You often hear software developers say "we cannot scale horizontally but we can scale
vertically" that means we cannot buy a bigger server but lets buy more
smaller servers, or in this case we cannot put more power to single core but we
can have more cores.

The problem is that lot of programming and software development history was
about taking advantage of a single core. That's why most modern software is
still written this way (e.g. Microsoft Excel still running on single core).
To get things even worse, upon that existing
 software developers are stacking more single core software.

That's why we are stuck in this Moors law nightmare.

But if the software was
written "concurrently"  then you have no problem to use multiple cores.

So what does "concurrently" mean ?

Imagine you have a shuffled deck of cards, and it's only you who can
sort them in order. Cool you are single core processor.

Now imagine you
have 3 friends over (so 4 of you) and you will give to each 25% of the
deck cards  to sort out and then you will just join them together.
Awesome Now you are 4 core processor running program concurrently

Now imagine same
situation where you don't want your 3 friends to touch the cards so  you
will sort them together while your buddies are watching TV. Now you are
4 core processor running program on single core (e.g. most of the world
software)

So why aren't software developers writing programs this way ? Well some
has to do with the fact that there was never too much pressure to
develop differently. First two core processor was introduced in 2005
with plenty of power for single core. Now in 2017 we are facing the
reality that sigle core is not enough. It's like running on petrol
engine till last drop of oil is spent and wondering why everyone didn't
switch to electric cars earlier. 

Another factor is Education both in computer classes and around the
internet. Lot of existing well respected programming
materials are still describing how to work with single core only.

But the biggest factor is productivity. You see lot of existing
programming languages predicted this outcome and included a way how to
deal with processing on multiple cores. But the problem was that it
would add extra complexicity that would make software development
slower. That's why lot of companies sacrificed potentional future
eficiencity with imidiet productivity. 

But you cannot really blame them as it's natural selection in practice.
We choose the software with more features at better price, not the more
expensive software with less features that will work better in 5 years.

But the future is bright my friends.

Last couple of years there is huge mindset shifting in Software
Developer communities and pressure emphasis on concurrent programming.
Programmers are rediscovering old paradigms that are better dealing with
concurrency.


For those more technical folks: Functional programming is raising in popularity.
New laguages like Elixir, Go & Clojure  same as older Erlang, Haskal are
enjoying huge comeback.
Functional programming languages are awesome because they can achieve
communication between multiple cores really easily.

Yes I know I know Object oriented  languages
like  Java, Ruby,... can do concurrent programming as well but there is
"thread" level locking of state that is to some degree working but would
never reach 100% potential of all cores)


 So the only limitation at this
point are (unfortunately) people and cost of rewriting popular software
concurrently. Conclusion  although protein chips sound cool the truth is
that for next decade silicone chips are here to stay. It's just you will
have 128 core laptop. The Quantum computer is definitely the future but
at this point way ahead of it's time.﻿
Show less
REPLY


some servers have 64 core

