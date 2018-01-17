# Remote working ? Use VPN !

Remote working is being more and more popular amongst more and more
companies.  But one thing we must not to forget is security of your
internet connection.

You see lot of employers/employees misunderstood the term "remote
working" as "home office". This is not true. When you are working
remotely you are working "remote" from the main office. You can be
working from home, but you may be working from coffee place down the
road, from public library, from shared work space.

In all this places you need to connect to internet and this is what can
get you and your company to trouble.


### What could go wrong ?

First of all you need to understand how networks works

Whew you are in on a public work place (coffee place, library) you  probably
won't be able to plug into your laptop an ethernet cable.

> And even if you could do that, would you ? WiFi is way more comfortable.

Therefore you
would connect to the internet via WiFi to internet router within that
building:



```

[myLaptop] - - - - - WiFi- \

[someone else] - - - WiFi- - --[WiFi Router] ------ ... ----[Internet]

[someone else] - - - WiFi- /       |
                                   |
                                [admin - someone else]

```

Now here is a first question, Who is that "Someone Else" ? Your and
(Everyone else) trafic is going via the same router. Whoever is in
control of that router can be "man in the middle attack" intercepting
your packets:



```

[myLaptop] - - - - - WiFi- \

[someone else] - - - WiFi- - --[WiFi Router] -- [man in the middle]---- ... ----[Internet]
                                                 /
[someone else] - - - WiFi- /       |            /
                                   |           /
                                [admin - someone else]

```


Ok let say you know who the admin is, he's a great guy he would never do
such a thing. Well you still have a situation that someone else can
"sniff" for the packets in the air (after all WiFi is transfering packets via
waves in the air):




```
( ( ( ( [someone else SNIFF SNIFF] ) ) )
  ( ( ( ( () ) ) ) ) ) ) 
      ( ( () ) ) )
  ( ( ( ( () ) ) ) ) ) ) 
( ( ( ( [myLaptop] ) ) ) ) )- - - - - WiFi- - - - - -  \
   ( ( ( ( () ) ) ) ) ) )                               \
       ( ( () ) ) )                                      \
   ( ( ( ( () ) ) ) ) ) )                                 \
( ( ( ( [someone else SNIFF SNIFF] ) ) ) - - - WiFi- - --[WiFi Router]  ----[Internet]
   ( ( ( ( () ) ) ) ) ) )
       ( ( () ) ) )

```

As you can see for Sniffing packets you don't even have to be part of
the network, you can just be outside of the building in a black van (of course) running
Sniffing application

> Really it's not that hard. You don't have to be experienced hacker/cracker.
> Any kid can download [BlackTrack linux](https://www.backtrack-linux.org) (Linux distribution designed
> for pen-testing company networks) and run some of the built in tools.
>
> Speaking of which, when I've first moved
> to Prague for a jobhunt, me and my friend we were living in rented out
> campus room (as we were broke and it was the cheapest option). The campus had WiFi but they refused to give us the
> access. Only the students were allowed to use it. Friend downloaded
> Blacktrack, run some tools over night next morning we had WiFi access.
> This was like 10 years ago, and security since then improved a lot but
> still gives you a glimps of "where is a will there is a way"
>
> B.T.W that campus was one of the best IT & Networking school campus of Prague.


Ok let say you trust everyone in the room and outside the room there is
just desert and no-one can sniff your packets. In 90% cases you are dealing with this scenario:

```

[myLaptop] - - - - WiFi- \

[myCoworker] - - - WiFi- - --[WiFi Router] ------[Ethernet/Optic Cable]-------[ISP]-----[Internet]----[ServerYouWantToConnectTo]

[myCoworker] - - - WiFi- /       |
                                 |
                              [Admin]

```

As you can see there are lot of nodes there till your request (from your
laptop) will get to the server.

Who is your ISP (internet service provider) ?
* Are they trust worthy ?
* Do they keep logs?  (e.g. if you download copyright item torrents ISP will send you a letter on how owner will sue you) `<3`

> Not to mention ISPs due to abolished Net Neutrality will be blacklisting
> some websites in USA [more on that](https://www.youtube.com/watch?v=bd27PgNJNIo)

You need to realize all your traffic goes via ISP.







### What about my home network ?

Your is in 98% cases safe. Usually if you are living in well know
neighbourhood several years surounded with friendly elderly people or 
live in a cabin several miles from nearest neighbour
I almost certain no-one will sniff for your packets.




In last couple of mont
