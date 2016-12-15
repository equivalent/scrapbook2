https://www.youtube.com/watch?v=W7wj7EDrSko

 by Jeremy Keith

# PATCH vs PUT vs yours client's firewall

Recently I wrote article [PATCH vs PUT and the PATCH JSON syntax war](http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war).
In it I was talking about PATCH vs PUT HTTP methods and wide argument on
the JSON syntax.

This article follow-up to that topic related to our very own "500-mile problem" like
story related to the topic.

> The term "500-mile problem" refers
> to a hilarious article [The case of the 500-mile email](https://www.ibiblio.org/harris/500milemail.html).
> It's a story of how sys-admin received a bug report that *"emails are not
> being delivered over 500 miles"* and it's probably the best example of how non-deterministic computers really are
> because they are made by people.

## The story

> This article is reflecting collective effort of [Pobble Devel team](https://github.com/Pobble) to solve the issue.

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
releases. Nothing worked.

Soon we discovered that 405 responses had some headers not coming from our side.
It seems to us that the Firewall/nany-software/caching-proxy(Squid)  was blocking the PATCH on Ajax calls for some reason.


So healthy request before the bug was like this:

```
| Laptop PATCH  ->  Clients Firewal   ->   Load Balancer   ->  Nginx proxy  -> Rails app (200 response) |
```

After the bug:

```
| Laptop PATCH ->  Clients Firewal  (405 response)   |
```

To this day we still don't know why this was happening. I guess it has
something to do with the fact that PATCH method was introduced several years later than
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

> This does not apply for `member { patch :custom_update; }` but when
> following Rails best practices there are not many of those.

## So why was it happening ?

Originally when we stumble across this problem we've done what any
good web-developers should do: we've started to look for answers before
implementing cow-boy solutions.

When no answers could be found we asked for help. I've posted question to [StackOverflow](http://stackoverflow.com/questions/40970057/patch-method-blocked-by-a-firewall) and
to [Reddit](https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/) but several days there was no answer.
Therefore we went with the PUT solution and we hopped for the best. And
it worked, no issues were reported.

Then finally out of nowhere Redit user [1110101010](https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/)
shed light on the problem few weeks later.

> I will try to summarize the arguments in this post but I do recommend to read the entire discussion https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/

For the first part I will just copy entire [user 1110101010](https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/) explanation as he covered it really well:

> * Methods HEAD, GET, POST were introduced in HTTP/1.0.
> * Methods OPTIONS, PUT, DELETE, TRACE, CONNECT were introduced in HTTP/1.1.
> * PATCH is an odd beast as it was added later, separate from those specs, and its definition is as imprecise and generic as the one we can see for POST in either spec.
>
> While the HTTP has since been rewritten in a new set of modular RFCs, it's very easy to see how certain clients, intermediaries and servers might refuse to process PATCH requests, and they'd still be following the original HTTP/1.1 RFC correctly.
>
> The only reason we use HTTP to communicate with APIs is because it's ubiquitous, not because it's a marvel of engineering, if we have to be honest. Considering PATCH doesn't truly offer any objective benefits to POST in terms of semantics, and the distinction between POST and PATCH can be at best argued to be a matter of fuzzy convention, its use would be hard to justify from an engineering point of view
>
> It's not coincidental that while HTTP keeps adding methods, HTML still only supports forms that cover HTTP/1.0 (i.e. GET and POST, and the implied HEAD request for facilitating some levels of GET response caches). My recommendation is to stick to these as well, for widest compatibility.
>

## PUT is not there to replace PATCH !

Next wave of discussion was about the PUT replacing the PATCH decision.

To sum



Back to the article [PATCH vs PUT and the PATCH JSON syntax war](http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war) and Rails JSON syntax for PATCH

So therefore chill, Rails way of doing PATCH is fine.

At least you can use PATCH ! :)






## Resources

* [405 status checkupdown.com](http://www.checkupdown.com/status/E405.html)
* [troubleshooting 405](https://www.asp.net/web-api/overview/testing-and-debugging/troubleshooting-http-405-errors-after-publishing-web-api-applications)
* [my SO Question on this problem](http://stackoverflow.com/questions/40970057/patch-method-blocked-by-a-firewall)
* [my Reddit Question on this problem](https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/)

Article is second part of article: http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war

