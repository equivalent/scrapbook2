# Chromebook for Web Developers

![''](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2015/chromebook.jpg)

Now this may sound stupid but It's true.

I'm not just talking about some basic frontend debugging, I'm not
just talking about some JavaScript frontend framework development or
ChromeApp development. I'm not even talking about reinstalling Linux on a Chromebook or running
[Crouton](https://github.com/dnschneid/crouton) environment, or some
weird expensive Chromebook.

No Sir (...or Madam ) I'm talking about writing WebApp backend code,
running tests, deploying the app from a brand new $200 - $300 Chromebook.

> User `MindPlace` from [Reddit discussion](https://www.reddit.com/r/ruby/comments/40oxcy/chromebook_for_webdevelopers/)
> told me that he managed to get a deal `$60` for his Chromebook
> as it was returned to the store.

There are already some articles on experience that Web-Developers had
developing code on Chromebooks:

* https://divshot.com/blog/tips/using-a-chromebook-for-web-development/
* https://medium.com/@martinmalinda/ultimate-guide-for-web-development-on-chromebook-part-1-crouton-2ec2e6bb2a2d#.r7bn4vqpx

...I just though I'll bring to community another article with my experience from different angle.

If you had by any chance read my previous blog posts before you may know that I'm a Full Stack Ruby on Rails Developer. I daily write tone of code on both Backend & Frontend side +
but load of DevOps. I'm a huge proponent of testing, TDD, BDD, CI tools.
I even do some level of UX design, wireframing + some
level of design alterations (we call those people Photoshop guys)

The reason why I'm mentioning all of this is to present a view that on
daily base I am working with servers, I write code for living,
I am writing and running tests, I am doing deployments,
and all that other stuff and yes one can survive
with a Chromebook doing that.

I've been using my [2015 HP Chromebook 14](https://www.google.com/chrome/devices/hp-chromebook-14/)
in summer 2015 for like 3-4 months developing medium-large size Ruby on Rails application
for the company I was working for during that period.
*To be honest I was not using Chromebook all the time*. I've usually worked
3 days a week from home, during which I was using Chromebook most of
the time. Remaining 2 days in the office I was developing on a work
computer.

The biggest mind shift is that it's no longer the computing power of the
laptop in your hands doing that but the VM you are connected to.

## The new age of terminals

Before we go deeper let me present the stage (or just skip this section)

In the old days there was no such thing as having a huge computer power
at your hands. Everyone was connecting via terminals to a huge
computer that was doing the work remotely for them. Then came the era of Personal
Computers where each person had computer power at their desks. Now we
are in the era where nearly every web-developer has a shiny `i7` MacBook with
SSD drive, where tests are running blazing fast and we connect to remote
computer only if server is down and we need to debug.

If you are a web-developer and not a linux server sys-admin or
DevOps guy it kinda feels that the era of Terminals is long gone. Well in my opinion
it was just replaced by era of Cloud.

Think about it:

* we store all our assets and documents on Dropbox or Google Drive
* yes we run the tests on our laptops, but we also run them
on hosted CI tools like [CodeShip](http://codeship.com/),
[TravisCI](https://travis-ci.com/), [Circle cI](https://circleci.com/)
* lot of time we don't need to dig around with Git commands to merge our code changes, we just use Github web interface
* we no longer ssh to the servers to do the deployment we configure our
[Github webhooks](https://developer.github.com/webhooks/) to trigger
builds for us.
* we no longer have to configure our entire Server Rack
ourself we push applications to Cloud hostings like
[Heroku](www.heroku.com).
* our Docker images get automatically build by the Docker Registry
  itself by pulling content from Github ([DockerHub](https://docs.docker.com/docker-hub/builds/),
  [Quay.io](https://quay.io) )
* our email / communication tools has web interface (Slack, Gmail,
  Hangout,...)
* Even our personal holiday photos are on Google photos or Flicker

Lot of us hardly ever lunch any desktop applications to get stuff done.
It really starting to become an era of modern web-interface terminals.

## IDE in the Cloud

Last few year I'm witnessing raise of several "Cloud IDEs". They
basically provide a web interface editor and usually a small VM to do
your development and run the tests, or you can connect your VM.

I've personally tried:

* [cloud9](https://c9.io/),
* [codeanywhere](https://codeanywhere.com/)
* [koding.com](https://koding.com/)

> Google search for "Cloude IDE" and you'll get more

Cloud9 and Codeanywhere appear to me really similar. They have wider
range of pricing (therefore you can have a cheaper plan) than
koding.com.

For me Cloud9 and Codeanywhere feels more IDE focused and Pair programming
focused (https://blog.codeanywhere.com/share-links-pair-programming/, https://www.youtube.com/watch?v=RLKEaMs1p10),
accessibility focused (codeanywhere has a mobile app, so you can
seriously code anywhere `:)` ) and Koding.com was giving you bigger VM and
for some reason the web interface is faster on a poor network.

Unfortunatelly I cannot give you much feedback on the IDE experience as I'm a
**Vim** user and I didn't spend much time in the provided IDE. Also I didn't
convince my co-workers to try any of the cloud IDE tools I have no
feedback on the pair-programming features either. Hovever as it is with
any web-application software, they rapidly evolve features so I highly
recommend to just play around and get the feeling yourself. All 3 (and
also other) cloud IDE providers provide Free plan to play around the
only catch is that you need to shut them down and lunch them back up
after while. You don't have to buy a Chromebook to try them out.

In the end I end up with Koding.com paid plan for couple of weeks and I
was just using Vim editor for editing code. The only big problem for any Vim
user on a Chromebook will be the infamous `Ctrl+w` shortcut is configured
to close browser tab. There is no way to change this, the only
workaround is either to remap split screen switch to other key combination or
just use `Alt+Ctrl+w` which is basically the same thing by default.

The VM provided in all three of these cloud IDE providers was fast
enough to run tests, in some cases the tests were actually faster on
the VM (1 core) than my work laptop (Intel i5 4th gen + SSD PRO drive). Think about it
VM's are in a server room with air-conditioning. You are sometimes running
your tests while you're sitting in a couch with your laptop on your lap
listening to music, with 50 firefox tabs open and mining bitcoins.

I was running "local" Ruby on Rails development server and using the
public DNS url of the Koding VM to access it, so it felt like I'm
working on a real laptop.

So that I comply with strict security policy of my company I've ended up actually
connecting from koding.com VM via encrypted ssh key to external VM (AWS EC2 micro instance)
where I had the code & ssh keys to connect to other servers and so on.
From there I was doing all the magic, developing code, running tests,
scheduling deployment, ssh to other servers when stuff went down.

## SSH for hard-core linux/vim/emacs audience

After a while I realized I don't need Web-Interface to connect to this AWS EC2 micro instance VM.
Chromebook has a extension SSH tool [Secure Shell](https://chrome.google.com/webstore/search/ssh)

> [AWS EC2 micro instance](https://aws.amazon.com/ec2/instance-types/) is eligible for
> [AWS free tier](https://aws.amazon.com/free/), so if you do your math correctly on provided resources
> you'll end up not paying a dime

All you have to do is to [generate ssh
keys](https://help.github.com/articles/generating-ssh-keys/) on some laptop or VM,
and copy the private key to Chromebook downloads folder. Then when you are
creating new connection in Chomebook Secure Shel extension, tell it to
use this key. Chromebook will then store this private key in some folder
outside Downloads folder, so then you can delete from Downloads folder.

> Remember kids, having a password on a server is irresponsible and
> stupid. Always prefer the SSH key connection.

The development process was exactly the same as I described in previous
section. I was writing code via a Vim, running tests on a VM, doing
deployments([Capistrano](http://capistranorb.com/)) no problemo.
I was running development Rails server and
connecting via AWS EC2 instance public DNS address or IP + port.

Everything worked like a charm, therefore I've unsubscribe form the
Koding.com paid plan and just had it as a backup in case my flat is
robbed and all my laptops are stolen and I need to do a fix from a
non-configured PC ;) .

## UX and Design

And then one day comes where you need to some wireframes for a client.
Are you using tools like Adobe Fireworks and Adobe Photoshop on a daily
base? Do you deliver website designs, templates, assets on daily base ?
Well I wont be helpful with that.

But If you're creating black/white/grey wireframes check online tool [UX
pin](https://www.uxpin.com/). If you are UX guy and newer tried it you would
be suprise how much you can do with a online tool. As a Linux guy
with lack of software options I've
use to use it way before my Chromebook experiment. It's really
comprehensive UX tool.

If you need to resize an image that a clumsy designer sent you in
wrong size, or you need to do some simple css image-sprite or image alteration for which
[Gimp](https://www.gimp.org/) would be good enough check out [Pixlr](https://pixlr.com).
Pixlr is a online Photoshop wannabe that contains lot of features (yes
layers included). You can can install Chrome extension for Pixlr that will give you bit better
usable interface.

## Holiday and Apocalypse  concern

Let say you are a Lead Web Developer or a DevOps person and you want to
go on a holiday. Your boss ask's you if you can bring your laptop with
you in case they have an unsolvable problem with server. You know just
in case. Because you are professional you will say no problem and pack
your $2000 i7 MacBook Profesional with custom component build with you.

Now you come to the check in to the hotel and you want to store your
precious Laptop in a save. Yet you discover the safe is 7 by 10 inch
tall and you cannot fit your precious expensive laptop. What will you do
? Shell you leave it under the bed? Hidden amongs towels in the wardrobe ?
Will you go to the reception and place it in a hotel safe ?

And most importantly, will you actually enjoy the holiday thinking about
weather your laptop is still there ?

Ok another scenario. You know on Friday you are invited to Metalcore
concert and there will be definitely a great [mosh pit](https://www.youtube.com/watch?v=73d8pMnMbKg).
Now you wont be able to keep your laptop in the office due to some made
up reason. Would you take $300 Chromebook or $2000
MacBook to the office that day ?

I'm a huge fan of idea that the best laptop backup ist the one you never have
to do; store stuff in the cloud, in git repo, in remote server and you
don't have to worry about what will happen if ....

Chromebook is built on top of that philosophy.

## What if I don't have internet ?

I'm mainly focusing this article for web-developers and all good
web-developers introduce changes only if they have metrics to prove their point.
How many times last month you were in a situation you had no internet in your office ?
...ok how about at home ?

Let say you are on Airport and you want to write some code. Have you got
your 4G Iphone or Android phone with you ? Cool press the HotSpot button.

If you like to code in a coffee shop or library there is always WiFi
(just always use secure VPN connection  more on that in topic below on security).

If you're saying: "but I want to write a code in a tube on my way home",
seriously how many times you done that past month in a crowded tube? You
know you're usually watching some screencasts on the phone
or listening some podcasts.

And if you are really concern about internet being down in the office
and you not able to work, you can have old computer somewhere in the
corner of the office and ssh-ing to it via a Chromebook and writing
your code there.

> **Update1:** in [Reddit discussion](https://www.reddit.com/r/rubyonrails/comments/40otiw/chromebook_for_ruby_on_rails_developers/)
> User `vinsneezel` pointed out that I skipped the topic of popular [Crouton](https://github.com/dnschneid/crouton).
> With Crouton you will run linux enviroment (Ubuntu, Debian) inside your Chromebook and therefore you have
> trully  connection agnostic enviroment directly on Chromebook.
> To be honest I didn't try Cruton therefore I cannot speek for it.

## Security

Chromebook by very definition is secure ([Chromebook security](https://support.google.com/Chromebook/answer/3438631?hl=en-GB)).
You don't store files, 99% of everything you open on a cloud
provider (probably with antivirus) like Gmail, Google Drive, Dropbox.
Only application that can be installed are Browser application for
Chrome.

Only thing from a security perspective that you need to be worried about
is whether your internet connection is secure. Yes we all have `https`
websites but even that stuff can be hacked and you would be suprised
how many websites are misconfigure to send your cookie even if accessed
from `http` That's why the sys-adming dude is so paranoid each time you are
mentioning that "you will be working from coffee place down the road
next Tuesday".

When you want to connect to public WiFi always connect via [VPN
connection](http://www.howtogeek.com/133680/htg-explains-what-is-a-vpn/).
Don't be cheap. There is no good free solution that you can trust (unless
your company has a VPN of their own). You can get really secure
and good commercial VPN for like $10 a month and yes Chromebook has really easy way
to set it up([How to set up VPN in Chromebook](https://support.google.com/Chromebook/answer/1282338?hl=en-GB)).
I'm using [TorGuard VPN](https://torguard.net/)  (no, it
has nothing to do with Tor network)

Then comes to VM security that you are connecting too. Just follow any
good practices that you would normally follow for a web-app server. If
you are new to servers, the basic rules are to keep your system up to date with
latest fixes, connect to VM via ssh key-pair not password and don't
open ports you necessary have to. You will probably survive first year
with just SSH port and port 80 on your VM.

## Overal Developer experience

On my HP 14 Chromebook the keyboard was really pleasant (until the
hardware issue). I must admit that Chrome OS developer introduced lot of
really cool keyboard shortcuts to various cool stuff. PC people won't be
missing the "windows" key, Mac people wont be missing the CMD key.

One thing to remember is that Chromebook is just one big browser. If you
use to work with workspaces in Ubuntu or OsX you will definitely
miss them. As I'm usually working on 3 things during a day it was hard
for me to switch context (as everything is just a Chrome tab). But if
you are a developer focusing on one thing and you don't have to be
switching context so often all the time I think you will actually enjoy the
experience.

Screen was really good. I love anti-gloss screens and this Chromebook
had 14 inch one. It wasn't HD resolution but for text editing you don't need that.

One thing that was really bad was the lack of memory on Chromebook. My
was just 2GB and that's ok for several tabs open. But once I started to
stream some music from Google Music or Youtube lot of time the
Chromebook run out of memory and crushed some tabs. This may however be
only with my model. I didn't extend memory in mine because I found a way
how to balance my memory power, but if this would be your plan make sure that you check if your
model is upgradable as some Chromebooks are not ([source](http://www.omgchrome.com/Chromebooks-can-upgraded/))
and definitely check some reviews before you buy.

## Conclusion

My previous company was security crazy to be honest. We couldn't use lot
of tools that were on the market. We had our own Jenkins CI our own
servers our own everything except Github. The chances  are you are
working in more enlighten environment where you guys are using TravisCI or
CodeShip or DockerHub automated image builds and therefore you have all
those cool automated 3rd party tools with you.

I've survived working on a Chromebook I'll bet you will too.

Do I recommend Chromebook as a primary computer ? Well, absolutely not !

Now, do I recommend you to  buy a Chromebook ? Well, not necessary, but
it's interesting experience.

In this article I was mainly standing ground for alternative way how
to develop software via a terminal connection / Cloud IDE. Like I said I'm a huge fan
of idea that the best computer backup is the one you don't have to do.
By having your development toolset outside your box you will loose offline possibility to
write software, but gain the freedom of not to care about when your laptop
crash.

Friend of my use to develop Rails application on Windows 7 as he was
composing music on that machine. For some time he was fighting the
dependency struggle but in the end he give up and just done dual boot
with Fedora. With similar approach he would not have to.

So don't buy Chromebook yet. Play around with idea *"how would it feel
like to be stuck with ssh and Chrome only"* for few weeks and if you find
it possible go for it. You may not be the most productive but it's a
nice alternative experience. At least you will have backup machine with good
battery power if you need to go on a hardcore holiday.

My estimates are that you will be productive on Chromebook the same as
you are productive on Mac or Ubuntu if you are just developing backend
code and write tests. You may not be as productive if you do bunch of other stuff along
that.

## Reasons why I don't use it anymore

Reason why I stopped using Chromebook was partly due
to keyboard faulty on my Chrombook. One thing to remember is that Chromebooks
are cheap so sometimes the hardware suffers due to the price.
After that it took me a while to schedule a replacement, so I kinda
switch back to my old PC habits.

During that time I also changed my job to contracting, where I'm using a lot Docker.
I'm a proponent of idea that [Docker images should
be build on developer machine not in the cloud](http://www.eq8.eu/blogs/17-build-docker-images-on-your-machine-or-in-the-cloud) therefore I needed to switch back to Ubuntu.

This was not the argument to switch from Chromebook, as I
could just build my Docker images on a larger AWS VM, however you know
how new contracts are, they expect miracles from you the first day, that's
why I switch to environment I'm familiar several years and I am the most
productive (Ubuntu Linux).

**UPDATE** New article on this released http://www.eq8.eu/blogs/43-deep-dive-to-cloud-coding

