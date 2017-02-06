# POST != Create and PUT != Update


Recently I wrote an article [PATCH vs PUT and the PATCH JSON syntax war](http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war) in which I wrote about PATCH vs PUT HTTP methods and wide argument on
the JSON syntax. Quite lot of developers read it (thank you for that),
but truth is there was lot of content that I wanted to include but due
to size I skipped. So therefore here is follow-up.

In this Article I will cover more taboo topic aspect of PUT, PATCH and overall REST approach of web-frameworks.

> If this article is too long for you and you don't want to read it all,
> the main point I want to present is that
> Ruby on Rails developers tend to think that HTTP method POST
> represents Create and PUT means Update. Well, not really. The CRUD
> mapping of modern web-frameworks just limits the scope  of these HTTP methods for
> sake of simplicity in code design.

Let me point out that in the previous article I strongly argue for my opinion, while this article is more chilled version.
I just want to extend reader's point of view around REST.
I don't want to change anything, I don't want to criticise anything,
I just want to give web-developers something to think about over the weekend.

## PATCH vs PUT vs yours client's firewall

First allow me to tell you my very own "500-mile problem" like
story.

> The term "500-mile problem" refers
> to a hilarious article [The case of the 500-mile email](https://www.ibiblio.org/harris/500milemail.html).
> It's a story of how sys-admin received a bug report that
> *"emails are not being delivered to clients located over 500 miles from server"*
> and it's probably the best example of how non-deterministic computers really are
> because they are made by people.

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
It seems to us that the Firewall or nany-software or caching-proxy  was blocking the PATCH on Ajax calls for some reason.


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

> This does not apply for routes defined via `member { patch :custom_update; }` but when
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

Next wave of discussion was about the my decision to use PUT to replace the PATCH functionality.

> I'm hoping you've read the previous article
> [PATCH vs PUT and the PATCH JSON syntax war](http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war)
> where I'm explaining what is idempotency or you know what is
> idempotency difference of PUT vs PATCH. If no please do so otherwise
> the next part will not make much sense.

In short let me quote user 1110101010:

> PUT is intended to replace a full resource, and be idempotent. While it's not out
> of the question, I doubt your PATCH  match those semantics. This can have an actual implication
> if an **intermediary decides to resend a PUT command to your server**.

Basically point is that although our Rails applications is able to replace PATCH with PUT with no effect, on
networking level there may be devices/routers that will fully respect the
HTTP specification and may try to resend your PUT requests if they
suspect that PUT failed.

> So an intermediary sees "PUT" and decides "I'm not getting a response,
> so this means I can re-send, as PUT is idempotent". The intermediary is simply following HTTP,
> according to spec.

So the counter argument may be: `"big deal, so we will update resource with same information twice"`

Well depends what you are doing.

If your "PUT #update" action is just
replacing attribute values on a record it may be no big deal.

If your PUT controller action is
incrementing counter (e.g. likes) then you may end up
with +2 likes instead of +1 like

```ruby
#  request_sent_at     | request        | db val |
#  2016-12-11 23:43:02 | PUT /inc_likes | 1      | incremented, just response got lost
#  2016-12-11 23:43:02 | router retry   | 2      | incremented, just response got lost
#  2016-12-11 23:43:03 | router retry   | 3      | 200/204(Success)
```

Well to be honest this may be overexagguration in Ruby on Rails case because
if you're submitting Form rendered with rails `form_for` it will include
`CSRF` token ([read more](http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)) that
is there to protect the same form being submitted several times.

But CSRF token is there not to ensure PUT will not misbehave but for
protecting you from attacks.

Truth is that lot of time I see junior Rails developers disable the
`protect_from_forgery` particular controller action when they have difficulties
implementing CSRF header into JavaScript libraries.

Also if you creating an API you will not be able to rely on this option.

So in other words PUT has a reason for existence in HTTP specification. It's "replacing" or "creating"
resource. So although Rails router may treat `Controller#update` action
as both `PUT` and `PATCH` avoid writing your forms or AJAX request to
use `PUT` unless you specifically matching the "replace" context.

# POST

So back to my story of the PATCH not working. What would be the best
practice to solve it from the *intermediary* device perspective ?

So PATCH is non-idempotent. We should not replace it with PUT as that is
idempotent. The only other HTTP method that is there from the beginning and is non-idempotent
is `POST`.

So answer is: I should use `POST` !

Now hold on ! Isn't that against REST ? Shouldn't the `POST` be used only for creating
records ???

That's exactly what I was originally  thinking as well. Rails just
applied this HTTP Method mapping to it's C.R.U.D. model.

```ruby
# Rails way:

#index  | GET        /items
#create | POST       /items
#show   | GET        /items/123
#update | PATCH/PUT  /items/123
#delete | DELETE     /items/123
```

There is nothing anti REST to map update POST for updating record.

```ruby
# theretical model:

#index  | GET        /items
#create | POST       /items
#show   | GET        /items/123
#update | POST       /items/123
#delete | DELETE     /items/123
```

To quote [restcookbook.com](http://restcookbook.com/HTTP%20Methods/put-vs-post/) on this:

> The HTTP methods POST and PUT aren't the HTTP equivalent of the CRUD's create and update.
> They both serve a different purpose. It's quite possible, valid and even preferred in some occasions,
> to use PUT to create resources, or use POST to update resources


## Conclusion

So should we rewrite the entire Rails router ?

...Well no.

Rails is Rails because is easily understandable and there are certain conventions like CRUD
that may the development experience just pleasure. There is always something
that could be done better according to technical best practices but with sacrifice of
understandability.

PATCH is perfectly fine ! Don't let this article discourage you
from using it. I just had really bad luck that somehow it was not
working with this one client.

I just wanted you to tell you this experience and little bit extend your
REST specification vs application framework convention understanding.

Just be aware that PUT **is not** synonym for PATCH just because Rails
behaves this way. Think twice before using PUT in your routes.


## Acknowledgement

* "PATCH vs PUT vs yours client's firewall" part of this article is reflecting collective effort of me and my collegues Anas, Luca, Peter, Matt to solve the issue.
* Special thanks to Reddit user 1110101010 for helping me understood everything mentioned in this article ([discussion](https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/))

## Resources

* [405 status checkupdown.com](http://www.checkupdown.com/status/E405.html)
* [troubleshooting 405](https://www.asp.net/web-api/overview/testing-and-debugging/troubleshooting-http-405-errors-after-publishing-web-api-applications)
* [my SO Question on this problem](http://stackoverflow.com/questions/40970057/patch-method-blocked-by-a-firewall)
* [my Reddit Question on this problem](https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/)
* http://restcookbook.com/HTTP%20Methods/put-vs-post/
* https://www.youtube.com/watch?v=W7wj7EDrSko
* http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf
* https://stormpath.com/blog/put-or-post
* https://www.reddit.com/r/rest/comments/5gkvba/patch_blocked_by_firewall/

Article is second part of article: http://www.eq8.eu/blogs/36-patch-vs-put-and-the-patch-json-syntax-war

