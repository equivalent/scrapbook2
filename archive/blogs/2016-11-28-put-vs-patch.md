# PATCH vs PUT and the PATCH JSON syntax war

There are several articles/discussions on parallels of PUT vs PATCH and
when to use one before other.
Also the main struggle recent years seems to be how to translate the RFC proposal
for PATCH JSON format.
I've decided to spam the internet with one more opinionated article on this topic
trying to explain everything one more time.


> First of all I'm a [Ruby on Rails](http://rubyonrails.org/) developer so I will reference some
> sources from RoR world, but everything I say in this article apply to any programming language / web-app
> framework. So please read the entire article before you start judging `:)`


![PATCH vs PUT](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/put-or-patch.jpg)

Probably best summarization of the difference I've ever seen is this comment
from [Rails PATCH Pull Request proposal](https://github.com/rails/rails/pull/505):

> PATCH and PUT have different semantics. PUT means create/replace and it is idempotent.
> PATCH means update (full or partial) and it is not idempotent. ([source](https://github.com/rails/rails/pull/505#issuecomment-3225622), author: [@fxn](https://github.com/fxn))

So what does this mean?

I will borrow definition of **Idempotency** from [www.restapitutorial.com](http://www.restapitutorial.com/lessons/idempotency.html):

You own a cow, you want to have more cows. So you hire sire service to impregnate your cow.
Now that the cow is pregnant, you want even more cows. Should you re-hire sire service to re-impregnate your
already pregnant cow even more ?

Can your cow get more pregnant ? Well, no! Cow impregnation is "Idempotent".

When it comes to REST API:

* PUT is Idempotent
* GET is Idempotent
* POST is non-idempotent
* PATCH is non-idempotent

![Idempotency table](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/put-patch-idempotance-table.png) 

> Idempotency table from https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol  (special thanks to [Matt](https://github.com/orgs/Pobble/people/MatthijsHovelynck) for pointing it out `;)`)

Funky stuff! Does that mean that with PATCH we can get multiple
resources ?

Short answer: no, long answer: first we need to understand
the [RFC](https://tools.ietf.org/html/rfc5789) behind PATCH.

Probably the most known article explaining PATCH is article
[Please do not PATCH like an idiot](http://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/)

As described there the "correct" way how to PATCH User's email is to send something like this:

```ruby
# PATCH /users/123

[
   { "op": "replace", "path": "/email", "value": "new.email@example.org" }
]
```


I've also seen a [version](http://softwareengineering.stackexchange.com/questions/260818/why-patch-method-is-not-idempotent) like this:

```ruby
# PATCH /users/123
{ "change": "email", "from": "benjamin@franklin.com", "to": "new.email@example.org" }
```

Quote from the article:

> You can use whatever format you want as "description of changes", as
> far as its semantics is well-defined.

...resulted to really interesting
[discussion](http://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/#disqus_thread) and I'm recommending
everyone to read it.

The bottom point is that if you send one request changing User email from "A"
to "B", and at the same time you request change from "A" to "C" second
requests should fail! And this way your PATCH it is non-idempotent.

```ruby
#  request_sent_at     | from      | to        | response
#  2016-12-11 23:43:02 | tom@me.me | foo@me.me | 200/204(Success)
#  2016-12-11 23:43:03 | tom@me.me | bar@me.me | 422 (Unprocessable Entity)
#  2016-12-11 23:43:04 | foo@me.me | car@me.me | 200/204(Success)
```

> Error handling status codes are defined here: https://tools.ietf.org/html/rfc5789

Therefore the article "Please do not PATCH like an idiot" is suggesting that **this way of PATCHing is incorrect**:

```ruby
# PATCH /users/123

{ "email": "new.email@example.org" }

# ..or

{"user":{ "email": "new.email@example.org" }}
```

This is due to the fact that you are **not describing a change**
therefore if you trigger them at the same time you would just say
"change User email to B", "change User email to C" and nothing would stop the second change.
Therefore this way your PATCH is technically idempotent.

```ruby
#  request_sent_at     | to        | response
#  2016-12-11 23:43:02 | foo@me.me | 200/204(Success)
#  2016-12-11 23:43:03 | bar@me.me | 200/204(Success)
#  2016-12-11 23:43:04 | car@me.me | 200/204(Success)
```

> [Ruby on Rails](http://rubyonrails.org/) developers are very well known to this format.

Does it mean that we all are doing it wrong ?

## Should we use PUT instead ?

Well, no! ...or maybe if it fits the definition.

PUT can be used not only for updating resources, but also for creating resources
too. Good example is [AWS S3 API](http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html).
There you will use PUT to add the document to your bucket, and it still
properly RESTful !

I would even argue that PUT has nothing to do with
"*update*" at all, but it represent "*replace*".

To truly comply witch RFC when you want to update user email with
PUT you would have to send all resource attributes (username, password,
address ...), not only the email (as you are "replacing" the resource with a new one)

So with PUT you are replacing or creating resource.
PATCH is for update.

> Both [release notes for PATCH in Ruby on Rails 4](http://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/)
> and [Original PATCH proposal Pull Request](https://github.com/rails/rails/pull/505)
> doesn't discuss the changeset `from -> to` scenario. **They are mainly discussing that PATCH
> represent the update action more than PUT.**

## Conclusion

So that doesn't solve the fact that some developer will say that this
`{"user":{ "email": "new.email@example.org" }}` PATCH style is wrong.

My opinion is that this is not really a problem. Lets be pragmatic, most of the time your
applications don't deal with such large number of request that suddenly
every endpoint would be updated at the same time.

When this day comes and you actually have
this kind of scenario on some endpoints you can pass & store version number
of a last request. So for example both requests will send header with same
"version" but along with the email change we would store the
version number (e.g. in Redis) and
therefore second request would still point to the old version,
therefore this request would be non-idempotent even with that JSON syntax.

```ruby
# PATCH /users/123
{"user":{ "email": "new.email@example.org" }, "version":"v1" }
```

```ruby
#  request_sent_at     | version   | to        | response
#  2016-12-11 23:43:02 | v1        | foo@me.me | 200/204(Success)
#  2016-12-11 23:43:03 | v1        | bar@me.me | 422 (Unprocessable Entity)
#  2016-12-11 23:43:04 | v2        | car@me.me | 200/204(Success)
```

Now this solution technically still
doesn't comply with PATCH RFC but like I said, check the arguments in
the [Don't PATCH like an idiot discussion](http://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/#disqus_thread)

In the end it's the end product and the team that realy matters,
not killing yourself over every rule.

Technically you are doing same level of RFC heresy when you do PUT
without passing all resource aruments as when you are PATCHing without changeset.
