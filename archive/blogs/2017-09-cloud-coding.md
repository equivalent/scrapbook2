# Cloud coding - How I'm doing it these days

These days you don't need an excellent laptop to work on a software. All you need
is to connect to a remote development server and write code there.
Well at least that's the theory, reality is bit more difficult than
that.

As I'm doing cloud coding for 2 - 2.5 years now (with some breaks in between)
and more and more people are interested in this style of
software development I'll let you know my
take on this.

I'll talk about "how to" cloud code, pair-coding, security, costs, ...


## What is Cloud coding

Normally when you are developing software you configure your programming
Language environment, web-server, test, development DB, test DB, source
control, ... in your Laptop. When you want to
test your application before sending it to production/staging server you
lunch `localhost` development server and you point your browser to
`http://localhost` (or similar). If any 3rd party API's need to be
called they are sent form your laptop.

![cloud-coding](https://raw.githubusercontent.com/equivalent/scrapbook2/ca17e3c39bc36f79141cbeb4a2a3ea33f888fb97/assets/images/2017/localhost-coding.png)

**Cloud Coding is  ideology in which you do your software development not in your
 laptop/computer but on a remote development server.** That means your language
environment, test DB, development Db, source control, ... everything is on a VM (Virtual Machine like AWS EC2 instance). Also everything related
to  external API's calls is set up on a remote VM. All you need to do is connect to that server / VM.

![cloud-coding](https://raw.githubusercontent.com/equivalent/scrapbook2/ca17e3c39bc36f79141cbeb4a2a3ea33f888fb97/assets/images/2017/cloud-coding.png)

> In human terms: you don't hold anything related to software
> development in your
> laptop. No code, no Database no GIT repo, no you don't even run tests or development server.
> Everything is on a remote VM and you calling/run it from there.
>
> Ever heard of immutable/discardable servers ? Ok imagine immutable/discardable laptops. Literally.
> You should be able to come to work with new laptop every day without
> spending more than 2 min to continue working as usual.

Usually with this style of coding every
developer has their own VM to work on the problem. From there whey are
able to lunch their tests, web-server,  do deployments,...
but in theory there is no problem if multiple developer work on same
VM.

> Some cloud IDE providers don't refer to VM but to something like
> "buckets" which are basically preconfigured VMs for the technology you
> want to use. But they are VMs, just maybe limited in visible functionality.

## How to Cloud Code

In the past I wrote article [Chromebook for Web Developers](http://www.eq8.eu/blogs/18-chromebook-for-web-developers)
where I was pretty much explaining in depth the "how to" side of things. In
this article I want to mainly focus on darker side of things. So if you
are still not sure what I'm talking about after finishing this section then please read the [article](http://www.eq8.eu/blogs/18-chromebook-for-web-developers).

So in brief: There are several ways how to write code in the cloud.

### Cloude IDE

Most easiest way is just use Cloud IDE provider which is usually browser based IDE client
on top of linux virtual machine with some "goodies" like preconfigured
ftp, ssh, language environment, ... (it depends on provider really)

There are several of them on the market (just google "Cloud IDE"). In the past I've personally tried:

* [codeanywhere](https://codeanywhere.com/)
* [koding.com](https://koding.com/)
* [cloud9](https://c9.io/)

Honestly if you are looking for a review of them then this is not the
article. You will have to try them yourself as last 1.5 - 2 years I'm
using another approach of cloud coding that I'll talk in the next section.

But in brief: you Lunch browser, you open/login to cloud IDE and form
there you can open Editor tab, Terminal tab, you can lunch tests
directly in VM, lunch server and connect to public url of the VM, ...

> Since last time I've used Cloud IDEs some of them changed their market
> approach and are focusing on different style of a product. For example my
> favorite use to be koding.com as it was cheapest for the size of VM provided to single developer. Now
> they are more focusing on entire team collaborating rather individual
> price. So as I'm a cheap bastard I'm sometimes using "Codeanywhere" as
> there is possibility to connect your own VM for free ($0 per month).
>
> B.T.W. nope I'm not paid by anyone to write this. Just my experiences
> and recommendations. But I encourage you to try several of them
> yourself and don't be satisfied until you try the rest.

Positives:

* easy to start / experiment with this style of coding
* easy if you are Junior developer or developer that don't know much about VM's or linux
* browser based - this is super important as you can open inner
  tabs(terminal, editor, run tests) within same browser tab. You don't
  get this luxury with direct ssh connection (unless you use Tmux).
* you are usually able to plug your own VM if you are not happy with
  preconfigured one.

Negatives:

* security concerns (I'll talk about that in own section)
* if you are a Vim person the Editor is not the best thing for you. You
  can lunch Vim in terminal session but in practice sometimes the key
  binding you use to in Vim may not work. But I didn't try this
  recently. This may be fixed now days.

### SSH to VM Approach

Another way is just to lunch VM and SSH to the VM and do code editing
via CLI editor like [Vim](https://vim.sourceforge.io)

This is my prefered way of cloud coding. But this is because I've spent
30% of my 10 year web-developer life as DevOps ssh'd to server all the
time. I also use Vim / Gvim on every day base 7 years now. So it's
really up to you if you want to go that path. I personally have nothing
against Cloude IDE solutions.

> For Vim users I https://github.com/carlhuda/janus todo 

It may be bit inconvinient that you will have to ssh to the VM several
times (e.g. one connection for Vim, one for running tests, one for
running server / logs, ...) so I recommend you to check out
[Tmux](https://github.com/tmux/tmux/wiki) This way you can emulate
multiple windows in one SSH connection.

Personally I use several ssh sessions.

One annoying bit about this is that if your ssh connection is dropped
(your ISP generates new IP, your VPN connection drops and new IP is
generated) you may need to start over SSHing all over again. It takes
some practice before you get this right.

@todo benefits

### IDE connected via socket connection

I've heard that some Editors like ATOM can apparently do stream to your
server => You can do everything from your IDE as if your remote machine was
localhost

I didn't try it but if you try it out pls let me know how it is https://atom.io/packages/remote-atom.

### Remote Workspaces

Have you ever VCN connect to your colleague or Mom computer to solve an issue
? Cool then you know what I'm talking about. 

Basically VCN [Virtual Network Computing](https://en.wikipedia.org/wiki/Virtual_Network_Computing) is like streaming
remote computer on your screen. Something similar as when you lunch
VirtualBox but this is actual remote computer.

Now I'm not saying you should VCN to your Desktop installation based VM in your server-room
(although that could work too) but
Amazon Web Services Lunched product [AWS Workspaces](https://aws.amazon.com/workspaces/) which suppose to be a product
for something similar that VCN is doing. I didn't try it out as last
time I've checked there were only Windows instances availible.

So it may not be ready for us web-developers yet but something worth keeping
eye on. Also it's a good proof that lot of other companies see the
benefit of cloud workstation environments and we will see more and more
solutions if future.

One thing to consider doh is that it may be much more heavy on internet
traffic than Cloud IDE or SSH connection. So it may not be a solution if
you want to work like this on DSL connection.

## What are the benefits of Cloud Coding

Most obvious ones:

* If you lose / damage your laptop you are not screwed.
* If you are on holiday and you need to hotfix something you can
  actually do it from your Smartphone (yes I've done this several times,
  it is not super productive but it works !)
* Database dumps (if you are doing them) are more easily & faster transferable
  to development environment +
  more secure (as long as your VM is secure)


Points that need more attention:

#### more closer prod replication

Assuming your production server is Linux it's easily to replicate same
environment on your development machine (the VM) as on different os
Laptop (OsX & Windows may have different lib for same programming language)

This applies even for Docker environment. It's 2017 and Docker as a Devel environment on OsX still don't
work as good as on Linux distro when you need to mount local folders.
But that's another blog post topic.

#### 3rd party communication

Biggest argument against cloud development is "what if I want to work
offline" (e.g. in the tube). That could be true few years ago but lot of localhost
applications are already bound to be connected to internet.

Our development applications are dealing with external
3rd party API's (such as PayPal, Stripe, S3, ...). You may be mocking your tests when calling external
API's but when you want to debug in development environment and you want
to call sandbox environment for 3rd party provide you'll still need to make remote call from your laptop.

This way your laptop is more bound to internet connection than you tend
to acknowledge.

With cloud coding you don't care as internet connection is must have.w

External API calls are no issue as they are mate from consistent endpoint. For some security paranoid API's you
need to provide list of IP's / domain names from where they will allow
connection to their API.

But biggest argument is when you are dealing
with webhook calls from 3rd party solution (calls to your
development server when even occurs on 3rd party server - e.g.: Bank
Payment was accepted they will call your endpoint) When you are dealing
with laptop localhost development (unless you have static IP) you need to set up proxy endpoint
that will then allow your localhost receive this call (e.g.
[ngrok](https://ngrok.com)).

This all is just for Monolith development. If you are dealing with
Microservices you are more screwed.

Yes you can dockerize the
environment to some extend and run all the services in your localhost,
however if you are dealing with too many services you will run out of
memory pretty quickly (some companies operates like 150 services in
their prod, try to replicate that). Even 8 GB Ram laptops are not
enough.

Usually what is done in this case is that you lunch in your localhost only the
microservices you really need to work on (one or two) at that moment and you let it
communicate with remote staging/QA services (or you spawn spawn new
instances replicated just for your development purpose and killed
after you're done)

The point is that in all these cases you need to have internet
connection and usually you need to have secured endpoint that must be
whitelisted. In these cases you are far better off Cloud Coding than
developing on localhost laptop.

#### Cloud Age

Now days we are already way too bound to Cloud.

We have:

* solutions like [Github](https://github.com) for code reviews, code colaboration
* Continues Integration & Continues Delivery cloud solutions for
  tests/deployments like CodeShip, TravisCI, CircleCI, ...
* document sharing solutions like Dropbox, Google Drive
* communication solutions like Hangout, Skype, Slack

so honestly only thing that we don't have in the cloud is our
development environments. 

#### Paircoidng

You can paircode more easily. Usually you can add your colleagues ssh key
to your VM and two of you can pair code on same VM. Depending on what
tools you choose you may not have live code changes streamed but it's
still really good experience. **Especially if you work remotely.**

What I tend to do when teaching Junior develapers is that I'll spawn AWS
EC2 instance, configure Codeanywhere Cloude IDE access for Junior
developer (as it's free). He then works there entire time and when he needs to paircode with me I'll just ssh to the
instance and lunch Vim and help him solve the issue.

He usually see what I'm doing from google hangout screen share.

Definitely recommending this approach for any Paircoding activities.

## Security Concern



