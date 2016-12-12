# PATCH vs PUT vs yours client's firewall

> This article is reflecting collective effort of [Pobble Devel team](https://github.com/Pobble) to solve the issue.

Recently I wrote article [PATCH vs PUT and the PATCH JSON syntax war](http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war).
In it I was talking about PATCH vs PUT HTTP methods and wide argument on
the JSON syntax.

This article is more chilled follow-up
where I want to tell you our very own "500-mile problem" alike
story related to the topic.

> The term "500-mile problem" refers
> to a hilarious article [The case of the 500-mile email](https://www.ibiblio.org/harris/500milemail.html).
> It's a story of how sys-admin received a bug report that *"emails are not
> being delivered over 500 miles"* and it's probably the best example of how non-deterministic computers really are
> because they are made by people.

## The story

One of our potential clients was trying our platform and he/she reported
that he/she is not able to trigger update actions. We tested several browsers from several
different locations around the world via VPN and all was working from
everywhere.

One of the client sysadmins provided us his machine to do some
debugging via remote desktop connection. And he was right, updating some
parts of application was not working. We soon discovered that the only
part not working was PATCH on a XHR (Ajax) calls. They were responding
405 "Method not Allowed"

We tried everything browser debugging, analyzing headers, rolling back
releases. Nothing worked. Soon we discovered that 405 responses had some
Firewall headers. Firewall was blocking the PATCH on Ajax calls for some reason.


So healthy request before the bug was like this:

```
| Laptop PATCH  ->  Clients Firewal   ->   Load Balancer   ->  Nginx proxy  -> Rails app (200 response) |
```

After the bug:

```
| Laptop PATCH ->  Clients Firewal  (405 response)   |
```

To this day we still don't know why this was happening. I guess it has
something to do with the fact that PATCH method was introduced several years later then
 POST, PUT, GET, DELETE and the client could be using really really old
caching server that didn't know about PATCH method.

![Idempotency table](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/put-patch-idempotance-table.png) 

> Idempotency table from https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol

So easy solution! Tell the client: "fix your firewall !" ...right ?

Well whoever was in a situation that company business rely on every client knows
that sometimes this is not an answer.

Long story short we changed the API endpoint from PATCH to PUT in order
to not loose the clients.

Luckily for us Rails is treating `update`
action both `PUT` and `PATCH` if the `config/routes` is defined via `resources`.
Therefore the transition was super easy and painless

> This does not apply for `member do patch :custom_update; end` but when
> following Rails best practices there are not many of those.


Back to the article [PATCH vs PUT and the PATCH JSON syntax war](http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war) and Rails JSON syntax for PATCH

We can argue all day if our refactoring PATCH to PUT was right or
wrong my point is that sometimes life throws you a situation where you
cannot do only the "best practice". Our discussion on PATCH vs PUT and
idempotency ends up there.

So therefore chill, Rails way of doing PATCH is fine.

At least you can use PATCH ! :)

## Resources

* [405 status checkupdown.com](http://www.checkupdown.com/status/E405.html)
* [troubleshooting 405](https://www.asp.net/web-api/overview/testing-and-debugging/troubleshooting-http-405-errors-after-publishing-web-api-applications)
* [my SO Question on this problem](http://stackoverflow.com/questions/40970057/patch-method-blocked-by-a-firewall)

Article is second part of article: http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war

