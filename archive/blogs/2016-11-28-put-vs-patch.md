# PATCH vs PUT vs yours client's firewall

There are several articles/discussions on parallels of PUT vs PATCH and
when to  use one before other. I've decided to spam the internet with one more opinionated
article on this topic with my very own "500-mile problem" alike
story related to this topic.

> The term "500-mile problem" refers
> to a hilarious article [The case of the 500-mile email](https://www.ibiblio.org/harris/500milemail.html).
> It's a story of how sys-admin received a bug report that *"emails are not
> being deliverd over 500 miles"* and it's probably the best example of how non-deterministic computers really are
> because they are made by people.


## PATCH vs PUT Ruby on Rails

![](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/put-or-patch.jpg)

Probably best summarization of the difference I've ever seen is this comment
from [Rails PATCH Pull Request proposal](https://github.com/rails/rails/pull/505):

> PATCH and PUT have different semantics. PUT means create/replace and it is idempotent. PATCH means update (full or partial) and it is not idempotent. ([source](https://github.com/rails/rails/pull/505#issuecomment-3225622), author: [@fxn](https://github.com/fxn))

So what does this mean?

I will borrow definition of **Idempotency** from [www.restapitutorial.com](http://www.restapitutorial.com/lessons/idempotency.html):

You own a cow, you want to have more cows. So you hire sire service to impregnate your cow.
Now that the cow is pregnant but you want event more cows should you re-hire sire service to re-impregnate your cow
even more ?

So can you cow get more pregnant ? Well, no. Cow is Idempotent.

When it comes to REST API
* PUT is Idempotent
* GET is Idempotent
* POST is non-idempotent
* PATCH is non-idempotent

![Idempotency table](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/put-patch-idempotance-table.png) 

> Idempotency table from https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol with extra thanks to my collegue [Matt](https://github.com/orgs/Pobble/people/MatthijsHovelynck) for pointing it out `;)`

Funky stuff! Does that mean that with PATCH we can get multiple
resources ?

Short answer: no, Long answer: first we need to understand
the [RFC](https://tools.ietf.org/html/rfc5789) behind PATCH

Probably the most known article explaining PATCH is article
[Please do not PATCH like an idiot](http://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/)

As described there the "correct" way how to PATCH User's email is to send something like this:

```json
PATCH /users/123

[
   { "op": "replace", "path": "/email", "value": "new.email@example.org" }
]
```


I've also seen a [version](http://softwareengineering.stackexchange.com/questions/260818/why-patch-method-is-not-idempotent) like this:

```json
PATCH /users/123
{ "change": "email", "from": "benjamin@franklin.com", "to": "new.email@example.org" }
```

Quote from the article:

> You can use whatever format you want as [description of changes], as
> far as its semantics is well-defined.

...resulted to really interesting
[discussion](http://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/#disqus_thread) and I'm recommending
everyone to read it.

The bottom point is that if you send one request changing User email from "A"
to "B", and at the same time you request change from "A" to "C" one of
the requests should fail! And this way your PATCH it is non-idempotent.


Therefore the Article is suggesting that **this is incorrect**:

```json
PATCH /users/123

{ "email": "new.email@example.org" }
```

This is due to the fact that you are **not describing a change**
therefore if you trigger them at the same time you would just say
"change User email to B", "change User email to C" and nothing would stop the second change.
Therefore this way your PATCH is technically idempotent.


Ruby on Rails developers are very well known to this format. Does it
mean that we all are doing it wrong ?

Both [release notes for PATCH in Rails](http://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/)
and [Original Pull Request](https://github.com/rails/rails/pull/505)
doesn't discuss this scenario. They are mainly discussing that PATCH
represent the update action more than PUT.

The reason is that PUT can be used not only for updating resources but for creating resources
too. Good example is [AWS S3 API](http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html).
You will use PUT to add the document to your bucket, and it still
properly RESTful !

I would event argue that PUT has nothing to do with
update at all but with "replace" and to truly comply witch RFC around
PUT you would have to send all resource attributes, not only email (as
you are replacing the resource with a new one)

So with PUT you are replacing or creating resource.
PATCH is for update

So that doesn't solve the fact that some people will say that Rails way of doing PATCH is wrong.

My opinion is that this is not a problem as you can pass & store version number
of a request. So for example both requests will send header with same
"version" but along with the email change we would store the version and
therefore second request would still point to the old version,
therefore request would be non-idempotent. Now this solution is technically still
doesn't fully comply with RFC but like I said, check the arguments in
the [Don't PATCH like an idiot discussion](http://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/#disqus_thread)


## The story of Firewall

> This part of an article is reflecting collective effort of [Pobble Devel team](https://github.com/Pobble) 

Several weeks ago we received a bug report that one of our clients
is not able to do updates. We tested several browsers from several
different locations around the world via VPN and all was working from
everywhere.

One of the sysadmins from the client provided us his machine to do some
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


So easy solution: "fix your firewall !" right ?

Well whoever was in a situation that company business rely on every client knows
that sometimes this is not an answer.

Long story short we changed the API endpoint from PATCH to PUT in order
to not loose the clients.

Luckily for us Rails is treating `update`
action both `PUT` and 'PATCH` if the route is defined via `resources`.
Therfore the transition was super easy and painless

> This does not apply for `member do patch :custom_update; end` but when
> following Rails best practices there are not many of those.

We can argue all day if this was right or
wrong my point is that sometimes life throws you a situation where you
cannot do only the "best practice". Our discussion on PATCH vs PUT and
idempotency ends up there.

So therefore chill, Rails way of doing PATCH is fine. At least you can
use PATCH ! :)



#### Other resources

http://www.checkupdown.com/status/E405.html
https://www.asp.net/web-api/overview/testing-and-debugging/troubleshooting-http-405-errors-after-publishing-web-api-applications

