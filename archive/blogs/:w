# Build Docker images on your machine or in the cloud ?

...or: There is no shame in not automating everything via a cool hosted tools.

[Quay.io](https://quay.io/) is Docker image repo (similar to [Docker Hub](https://hub.docker.com/))
where you can store your docker images or configure automated build of
Docker images when you push to certain Github branches. For example in my current role
there was a configured Github push trigger on branch `heads/live-*` (e.g. `live-20151221_0001`)
to build the image. After build is done I'll just use this image
to deploy to the server (Heroku, AWS ElasticBeanstalk, DigitalOcean,...)
via [CodeShip](https://codeship.com/), [Circle CI](https://circleci.com) or other hosted CI+deployment tool, or
directly from my laptop.

First of all don't get me wrong, I really enjoyed Quay.io and ideas behind
it + I'm a huge fan of any automation that could be done outside of my
laptop. In fact I  even use to write [Web-App backend code on a Chromebook](http://www.eq8.eu/blogs/18-chromebook-for-web-developers),
as the level of automation in my previous role was so system agnostic.

Now the Quay.io automatic build works like a charm for most application,
it's just I've found the automatic built problematic for the project I'm working
currently. My platform is Ruby on Rails monolith app
with butload of JS asset compilation to CDN and
therefore `Dockerfile` is bit tricky.

So long story short: When I built the docker image on my laptop with:

`docker build -t=quay.io/myorg/myproject:live-20151221_0001 .`

...and pushed to Quay.io

`docker push quay.io/myorg/myproject:live-20151221_0001`

... my deployment of this image worked.

But when I let the Quay.io to build the Docker image for me from Github
branch, it seems that some part went wrong and even though the build image was successful,
running container was crushing on the server.

I don't want to (and cannot) go into to much details why was this happening (in the end the problem is on our side not Quay side).
The point of this problem was the fact that this got me thinking about a question: **Who should be building the Docker image in the first place ?**.

Me on my laptop or hosted build tool ?

Letting hosted container service (or custom build machines) to build your images make perfect sense.
The setup is the same for everyone, junior developers don't have to care
about advanced Docker topics, when you have slow internet connection from
where you work it's a life saver,...

But if you are not building your production Docker images on your laptop
how do you know if they work before you push them live?
Of course that's why we have different environment
servers like Staging, or QA where we push the image before release, or
we can just build them remotely and just pull them to our laptops, but
that's not really my point.

I'm still new to Docker (well I think we all are as it's relatively new
technology) but when I started learning late 2014 every other talk I
watched presented Docker as a way how to **"ship the same container that
you have in your laptop to QA, staging, production and it just works"**.

That's why we have that whale with all the containers in the logo. You ship
collection of containters that works on one computer, to another
(whether it's a production VM or colleagues laptop)

![Docker Logo](https://www.docker.com/sites/default/files/legal/small_v.png)

So in my opinion developers should be building Docker images on their
local computers/laptops and then push them to Docker Registry, not let hosted tool to build/push
the images for them.

> It may be that if you are building microservice application the cloud
> solution is much better choice. I'm mainly talking from monolith perspective
> in this article.

For me Docker is more than just a tool for `production`. For me is also a
`development` tool (write application code for Docker running container
via linked volume) and `test` env tool (run tests on a container)
so it makes perfect sense for me to build the
production Docker image on my laptop as well and then ship it when/if it works.

If you need to ship to CI to run the tests, Ship the image that you had and tested on your
laptop. If you need to ship to production, ship the image that you had
on your laptop.

> This mainly apply for web-applications where all the configuration is done via
> Enviroment variables, like [12 Factor Apps](http://12factor.net/).
> Therefore building same Docker image can work on Development &
> Production...

That being said I don't stand any ground here. It may just happen that I'll
update this article in few months with few more lines in favor of remote
build idea.

> **Update:** The very next day that I drafted this article I was kicked
> by the idea behind it. I was working from home on a really crapy DSL
> connection. Guess who needed to build and push 3 builds of ~100MB images that day
> `:-/`.

All I'm saying is that there is no right or wrong. There is no harm in trying
new automation tools and new approaches to deploying builds. Just always reevaluate
after certain time if you and your
team are more or less productive. For now I'm favor of building my
docker images on my laptop and hiding my Chromebook in the wardrobe :).

relative keywords:

* Image built by Quay.io doesn't work but works on my laptop
