# CSRF protection on single page app API

![](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2017/csrf-protection-like-hell-it-is.jpg)

Let's first define our terms:

We are talking about Single Page apps as applications that will render
one page with JavaScript Framework (like Angular.js) and do all
remaining communication with backend  via API requests (e.g. JSON API
build in Ruby on Rails, Elixir Phoenix)

CSRF attack  protection as protection against  3rd party forcing users
browser to send
requests to a server where your user is authenticated with active session.
Let me quote example
from [Ruby on Rails security guideline](http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)


> Bob is sign in to a website `www.webapp.com` via browser
> session/cookie.
>
> Bob browses a message board and views a post from a hacker where there
> is a crafted HTML image element. The element references a command in
> Bob's project management application, rather than an image file: <img src="http://www.webapp.com/project/1/destroy">
>
> Bob's session at www.webapp.com is still alive, because he didn't log
> out a few minutes ago.
>
> By viewing the post, the browser finds an image tag. It tries to load
> the suspected image from www.webapp.com. As explained before, it will
> also send along the cookie with the valid session ID.
>
> The web application at www.webapp.com verifies the user information in
> the corresponding session hash and destroys the project with the ID 1.
> It then returns a result page which is an unexpected result for the
> browser, so it will not display the image.
>
> Bob doesn't notice the attack - but a few days later he finds out that
> project number one is gone.


Now yes this example uses GET request for delete but as is stated further down
in the guideline explained it's not that hard to make it send POST or
DELETE request. The point is that **it's easy to make users browser
 trigger malicious actions** event without session hijacking (stealing
session, cookie).

Usually you see CSRF attack protection mentioned in context of
"submitting Forms from your static website". I was recently reading more on CSRF protection related to API calls
and it's way too common that you see web-developers from various
technologies say: `you don't need CSRF attack protection on API`.

Let's put that to context. Usually they are talking about applications
in which API is expected to  be used by other client technologies than just  browser (e.g.: Android, iPhone, your smart fridge)`.
But usually with this context you don't use browser sessions.

> For example Serverless singe page applications sending requests to AWS
> Amazon API Gateway presign the request on Client side (in browser via
> JS) before sent via internet => no traditional browser sessions are
> used !

But if you are deailng with application that uses browser sessions (e.g.
Ruby on Rails developers using Devise Gem) and then that application is
comunicating with API you need CSRF protection !


## How to deal with CSRF API in Ruby on Rails web framework

Rails has
[protect_from_forgery](http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html#method-i-protect_from_forgery)  method that can be placed in Controller and that will prevent
any POST PUT PATCH DELETE calls happening unless CSRF token is provided

http://guides.rubyonrails.org/security.html#csrf-countermeasures

But the problem is this topic assumes that you are dealing with static
site that renders the CSRF token with Rails Helper `<%= csrf_meta_tags %>

```
<html>
  <head>
     <meta name="csrf-token"
content="oeKCxxxxxxxxxxxxxxxxxxxxxhnGIucBFGiKxgTi1dozvqaLsUZbq1Bfy1
AvrvVtCdQ==" />
```

But when dealing with single-page app that means you will have  fresh csrf-token only upon first render.

I seen people pointing to a solution where they configure backend to
store CSRF token to a cookie, and then FrontEnd framework (Angular,
React) will pick up the fresh value from the cookie.

> e.g. set CSRF token value to cookie named `XSRF-TOKEN` and then
> Angular will set value of `X-XSRF-TOKEN` header upon next request


So this way any malicious request to `DELETE http://www.webapp.com/project/1` will be without `CSRF-TOKEN` header => will not execute.

> Reason why  there is no way that malicious website can reed value
> of a cookie is that  cookies are bound to domain origin. That
> means `http://www.malicious-website-attacking-webapp.com` from where we
> will send request to `DELETE http://www.webapp.com/project/1` cannot
> read the cookie value of `www.webapp.com`.

I'm not going to write step by step tutorial as there are already good sources explaining this in detail:

* https://technpol.wordpress.com/2014/04/17/rails4-angularjs-csrf-and-devise/
* https://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on
* https://github.com/jsanders/angular_rails_csrf (gem solution)
* [deep details how CSRF Rails protection work](https://medium.com/rubyinside/a-deep-dive-into-csrf-protection-in-rails-19fa0a42c0ef)


One note doh. CSRF protection in Rails will not apply on GET & HEAD
requests. So if you by any chance have destructive action like `GET http://www.webapp.com/project/1/destroy` you will be screwed.


