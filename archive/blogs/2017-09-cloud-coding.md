# Deep dive to Cloud coding

These days you don't need an excellent laptop to write a software. All you need
is to connect to a remote development server and write code there.
Well at least that's the theory, reality is bit more difficult then
that.

As I'm doing cloud coding for 2 - 3 years now (with some breaks in between)
and more and more people are interested in this style of
software development I'll let you know my
take on this.

Given that I'm a web-developer I'll talk mainly about fullstack web-application development but to some extend this article may apply to other software development too.

> Some sub-topics like [Security, Pricing and Power](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-09-cloud-coding-security.md) were extracted out to separate
> sub-article you can find them in part 2 [here](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-09-cloud-coding-security.md)

## What is Cloud coding

Normally when you are developing software you configure your programming
Language environment, web-server, test, development DB, test DB, source
control and other stuff in your laptop. When you want to
test your application before sending it to production/staging server you
lunch `localhost` development server and you point your browser to
`http://localhost` (or similar). If any 3rd party APIs need to be
called (e.g. Paypal sandbox, Stripe, Facebook API) they are sent form your laptop.

![localhost-coding](https://raw.githubusercontent.com/equivalent/scrapbook2/ca17e3c39bc36f79141cbeb4a2a3ea33f888fb97/assets/images/2017/localhost-coding.png)

**Cloud Coding is  ideology in which you do your software development on a remote development server using your computer/laptop as a client device.**

That means your language
environment, test DB, development DB, source control, ... everything is on a VM (Virtual Machine) or dedicated server. Also all the related
external API calls (PayPal, Facebook API, ...)  is set up on a remote VM. All you need to do is connect to that VM.

> If you don't know what VM is please have a look at the bottom of the article for F.A.Q.

![cloud-coding](https://raw.githubusercontent.com/equivalent/scrapbook2/ca17e3c39bc36f79141cbeb4a2a3ea33f888fb97/assets/images/2017/cloud-coding.png)

> In human terms: you don't hold anything related to software
> development in your
> laptop. No code, no Database no GIT repo, no you don't even run tests or development server.
> Everything is on a remote VM and you run it from there.
> You write your code via text editor pluged to this VM (more on that
> later)
>
> Ever heard of immutable/discardable servers ? Ok, now imagine immutable/discardable laptops. Literally!
> You should be able to come to work with new laptop every day without
> spending more than 2 min to continue working as usual. One day you
> bring Macbook, next day Chromebook next day Windows machine and coding
> experience should be the same.

Usually with this style of coding every
developer has his own VM to work on. From there whey are
able to lunch his tests, web-server, do development operations,
deployments,... But in theory there is no problem if multiple developer work on same
VM as long as they have different databases configured.

> Some cloud IDE providers don't refer to VM but to something like
> "buckets" which are basically preconfigured VM for the technology you
> want to use. But technically they are VMs, just maybe limited in visible functionality.

## How to Cloud Code

In the past I wrote article [Chromebook for Web Developers](http://www.eq8.eu/blogs/18-chromebook-for-web-developers)
where I was pretty much explaining in depth the "how to" side of things. In
this article I want to mainly focus on benefits, downsides, [security
and cost](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-09-cloud-coding-security.md). So if you
are still not sure what I'm talking about after finishing this section then please read the [article](http://www.eq8.eu/blogs/18-chromebook-for-web-developers).

So in brief: There are several ways how to write code in the cloud:

### Cloud IDE

Most easiest way is just use Cloud IDE provider which is usually browser based IDE client
on top of Linux virtual machine with some "goodies" like preconfigured
FTP, SSH, language environment, ... (it depends on provider really)

Or some Cloud IDEs let you plug your own VM and they just provide the
browser text editor interface and terminal client.

There are several of them on the market (just google "Cloud IDE"). In the past I've personally tried:

* [codeanywhere](https://codeanywhere.com/)
* [koding.com](https://koding.com/)
* [cloud9](https://c9.io/)


![example Cloud IDE - codeanywhere](https://wcdn.codeanywhere.com/images/editor/editor.jpg)

> Image stolen from [https://codeanywhere.com](https://codeanywhere.com)


Honestly if you are looking for a review of them then this is not the
article. You will have to try them yourself as last 1.5 - 2 years I'm
using another approach of cloud coding that I'll talk in the next section.

But in brief: you Lunch browser, you open/login to cloud IDE and form
there you can open Editor tab, Terminal tab, you can lunch tests
directly in VM, lunch server and connect to public url of the VM, ...

> Since last time I've used Cloud IDEs some of them changed their market
> approach and are focusing on different style of a product. For example my
> favorite use to be koding.com as it was cheapest for the size of VM provided to single developer. Now
> they are more focusing on entire team collaborating rather than individual
> price. So as I'm a cheap bastard I'm sometimes using "Codeanywhere" as
> there is a possibility to connect your own VM for free ($0 per month).
>
> B.T.W. nope I'm not paid by anyone to write this. Just my experiences
> and recommendations. But I encourage you to try several of them
> yourself and don't be satisfied until you try the rest.

Positives:

* easy to start / experiment with this style of coding
* easy if you are Junior developer or developer that don't know much about VMs or Linux
* browser based - this is super important as you can open inner
  tabs(terminal, editor, run tests) within same browser tab. You don't
  get this luxury with direct SSH connection (unless you use Tmux).
* you are usually able to plug your own VM if you are not happy with
  preconfigured one.

Negatives:

* security concerns (I'll talk about that in own section [here](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-09-cloud-coding-security.md))
* if you are a Vim person the Editor is not the best thing for you. You
  can lunch Vim in terminal session but in practice sometimes the key
  binding you use to in Vim may not work. But I didn't try this
  recently. This may be fixed now days.

### SSH to VM approach

Another way is just to lunch VM and SSH to the VM and do code editing
via command line editor like [Vim](https://vim.sourceforge.io)

This is my favorit way of cloud coding. But this is because I've spent
30% of my 10 year web-developer life as DevOps SSHd to server several
times a day. I also use Vim / Gvim on every day base 7 years now. So it's
really up to you if you want to go that path. I personally have nothing
against Cloude IDE solutions.

> For Vim users I recommend to check out [Janus Vim](https://github.com/carlhuda/janus) it's a Vim Framework that has lot of well
> done plugins that makes Vim feel like modern IDE while still keeping
> command line editor nature.

It may be bit inconvinient that you will have to SSH to the VM several
times (e.g. one connection for Vim, one for running tests, one for
running server / logs, ...) so I recommend you to check out
[Tmux](https://github.com/tmux/tmux/wiki) This way you can emulate
multiple windows in one SSH connection.

Personally I use several SSH sessions.

One annoying bit about this is that if your SSH connection is dropped
(your ISP generates new IP, your VPN connection drops and new IP is
generated) you may need to start over SSHing all over again. It takes
some practice before you get this right.

Positives:

* DevOps/Sysadmin consistent - you will use same tools as when fixing
  server
* You can make this approach super secure
* Cloud IDE can change their product from one day to another, this
  approach guarantee stability.

Negatives

* May be too hardcore for folks not using Vim and terminal on daily
  base.
* When session expires/drops you need to reconnect and start over.
* Bit more configuration required to make this approach feels more
  natural (e.g. setting up bash aliases / custom scripts)

### IDE connected via socket connection

I've heard that some Editors like ATOM can apparently do stream to your
server => You can do everything from your IDE as if your remote machine was
localhost

I didn't try it but if you try it out please let me know how it is https://atom.io/packages/remote-atom.


### Remote Workspaces

Have you ever VCN connect to your colleague's or Mom's computer to solve an issue
? Cool then you know what I'm talking about. 

Basically VCN [Virtual Network Computing](https://en.wikipedia.org/wiki/Virtual_Network_Computing) is like streaming
remote computer on your screen. Something similar as when you lunch
VirtualBox but this is actual remote computer.

Now I'm not saying you should VCN to your Desktop installation based VM in your server-room
(although that could work too) but
Amazon Web Services Lunched product [AWS Workspaces](https://aws.amazon.com/workspaces/) which suppose to be a product
for something similar that VCN is doing. I didn't try it out as last
time I've checked there were only Windows instances available.

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

Points that need more attention:

#### Same region transfers

For example if your production VM and development VM is in the same AWS 
region and zone (like `us-east-1 a`) then you don't pay data transfers
if you move large files. Plus is super fast.

Further example: let say you need to create DB dump and transfer it to
development machine to debug some critical data bug. This way it's
faster &
more secure that copy dump to laptop (as long as your VM is secure. Honestly who can swear that
that 100% of his colleagues has encrypted hard drive it his/her laptop ?)

> For example larger scale projects in Ruby on Rails is a hell to run on Windows machine.

#### Development environment is closer to prod replication

Assuming your production server is Linux then it's easy to replicate same
environment on your development machine (the VM) as on different os
Laptop (OS X & Windows may have different dependent lib for same programming language)

This applies even for Docker environment. It's 2017 and Docker as a Devel environment on OS X still don't
work as good as on Linux distro when you need to mount local folders.
But that's another blog post topic.

#### 3rd party communication

Biggest argument against cloud development is "what if I want to work
offline" (e.g. in the tube). That could be true few years ago but lot of localhost
applications are already bound to be connected to internet.

Our development applications are dealing with external
3rd party APIs (such as PayPal, Stripe, S3, ...). You may be mocking your tests when calling external
APIs but when you want to debug in development environment and you want
to make real calls to sandbox environments that 3rd party provider provides, therefore you'll still need to make remote call from your laptop.

This way your laptop is more bound to internet connection than you tend
to acknowledge.

With cloud coding you don't care as internet connection is must have.

External API calls may not sound like no big deal as they are made to consistent endpoint
from Laptop or remote VM but for some security paranoid APIs you
need to provide list of IPs / domain names from where they will allow
connection to their API.

But biggest argument is when you are dealing
with webhook calls from 3rd party solution (calls to your
development server when event occurs on 3rd party server - e.g.: Bank
Payment was accepted they will call your endpoint). When you are dealing
with laptop localhost development you need to set up proxy endpoint
that will then allow your localhost to receive this call (e.g.
[ngrok](https://ngrok.com)) or queue mechanism on remote server/cloud
solution.

> Unless you have ISP with static IP and you never work outside same spot. But let's not go that way.

So already quite headache and this is are just arguments for Monolith development.
If you are dealing with
Microservices you are more screwed.

Yes you can Dockerize the
environment to some extend and run all the services in your localhost,
however if you are dealing with too many services you will run out of
memory pretty quickly (some companies operates like 150 services in
their prod, try to replicate that! Even 8 GB Ram laptops are not
enough)

Usually what is done when you have so many services  is that you lunch on your machine only
microservices you really need to work on (one or two) and you let them
communicate with remote staging/QA services. Or if your company has a
clever DevOps team they can set up for you server orchestration task to spawn fresh  new
VM instances replicating those other missing services just for
development purpose and you tell your
localhost microservices to communicate with them. Once you are done
you kill these development replicas.

The point is that in all these cases you need to have internet
connection and usually you need to have secured endpoint pointing to
your Laptop that must be
whitelisted in firewall. In these cases you are far better off Cloud Coding than
developing on laptop localhost.

#### Cloud Age

Now days we are already way too bound to Cloud.

We have:

* solutions like Github for code reviews, code collaboration
* Continues Integration & Continues Delivery cloud solutions for
  tests/deployments like CodeShip, TravisCI, CircleCI, ...
* document sharing solutions like Dropbox, Google Drive
* communication solutions like Hangout, Skype, Slack

So honestly only thing that we don't have in the cloud is our
development environments.

#### Paircoidng

You can paircode more easily. Usually you can add your colleagues SSH key
to your VM / allow access to your Cloud IDE profile and two of you can pair code on same VM. Depending on what
tools you choose you may not have live code changes streamed in real
time but it's still a really good experience. **Especially if you work remotely.**

> What I tend to do when teaching Junior develapers is that I'll spawn AWS
> EC2 instance VM, configure Codeanywhere Cloude IDE access to it for Junior
> developer (as it's free). He then works on this VM via Cloud IDE the entire time and when he needs to
> paircode with me I'll just SSH to the
> instance and lunch Vim and help him solve the issue.
>
> He usually see what I'm doing from google hangout screen share  and I
> see his code.

Definitely recommending this approach for any Paircoding activities.

## How I'm using Cloud Coding in Reality

You know how I've said that with Cloud Coding you should not have
anything on your laptop and internet connection is not issue?

![I've lied](https://i.imgur.com/6PlRXhI.gif)

Well theory is correct if in your office/home you have optic internet,
or you are connected to your laptop via Ethernet cable
and wherever you travel is a 4G mobile broadband.

But as soon as you are introducing more fragile parts to your connection
with server (e.g. VPN connection for extra WiFi security, reasonable SSH
connection termination, and other goodies (I'm talking about this more in [Security
Section](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-09-cloud-coding-security.md)) you may find it's becoming harder to keep up.

> Last 7 years I've moved flat 10 times (not kidding). Everywhere I moved was a DSL internet
> nd not even the good "high speed"  DSL. Nope. My last DSL was 8Mbit/s.
> I was living in quite modern cities like Prague, London & now Nitra. I just have terrible luck that
> the flats I like usually have terrible Broadband options :(
>
> Now don't get me wrong DSL is more than enough for several dozen SSH connections. I just wanted to give you example that not all of us live in the "Optic internet" age.

So in practice I do have project cloned on my laptop (the horror, I know) but 
I just  for test environment to write TDD / BDD code around parts of application that don't need
connection to internet (deep monolith stuff).

I have cloud coding VM set up and whenever I need to develop something
related to external calls or actually to lunch development server then I
ssh to it. I would say it's  50:50 time spent relation.


## Conclusion

Programming languages are tools, databases (relational or NoSQL, ..) are tools, Editors are tools.
Same applies to Cloud coding: it's a Tool.

There is no silver bullet.

There are developers that will curse it, there are developers that will
praise it to the sky. I give you best arguments for it I could. Now it's up
to you to try it yourself.

Just two things:

1. Please take seriously and respect developers that chose this style of
coding. This style of software development can be compared to Frontend
discussion around Single Page Websites several years ago. Everyone was
 laughing at developers propagating them and now single page apps pretty much took over the world :)
2. Before you clone your company repo to VM, read upon a security !!!
   [here](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-09-cloud-coding-security.md)


### Related articles

* [Deep dive to Cloud coding Part 2](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2017-09-cloud-coding-security.md)
* [Chromebook for web-developers](http://www.eq8.eu/blogs/18-chromebook-for-web-developers)

#### F.A.Q.

##### What is Virtual Machine (VM)

[Virtual Machine](https://en.wikipedia.org/wiki/Virtual_machine)
is a running instance emulating computer system (such as linux server)
on a cloud provider (e.g.: [AWS EC2](https://aws.amazon.com/ec2/), [Digital Ocean](https://www.digitalocean.com/pricing/), [Linode](https://www.linode.com/pricing), ...)
So for example you have virtual Ubuntu server without the need to buy
a Server Computer and plug it into a Internet and pay electricity and
internet bill. You just pay the cloud provider.


