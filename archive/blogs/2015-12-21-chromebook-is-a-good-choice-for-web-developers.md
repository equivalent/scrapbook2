# Chromebook is a good choice for Web Developers

Now this may sound stupid but It's true.

I'm not just talking about some basic frontend debugging, I'm not
just talking about some JavaScript frontend framework development or
ChromeApp development. I'm not even talking about reinstalling Linux on a Chromebook or running
[Crouton](https://github.com/dnschneid/crouton) environment, or some
weird expensive Chromebook.

No Sir (...or Madam ) I'm talking about writing WebApp backend code,
running tests, deploying the app from a brand new $200 - $300 Chromebook.

There are already some articles on experience that Web-Developers had
developing code on Chromebooks:

* https://divshot.com/blog/tips/using-a-chromebook-for-web-development/
* https://medium.com/@martinmalinda/ultimate-guide-for-web-development-on-chromebook-part-1-crouton-2ec2e6bb2a2d#.r7bn4vqpx

...I just though I'll bring to comunity another article with my experience.

If you had by any chance red my previous blog posts before you may know that I'm a Full Stack Ruby on Rails
Developer. I daily write tone of code on both Backend & Frontend side +
butload of DevOps. I'm a huge proponent of testing, TDD, BDD, CI tools.
I even do some level of UX design, wireframing + some
level of design alterations (we call those people Photoshop guys)

The reason why I'm mentioning all of this is to present a view that on
daily base I am working with servers, I am writing and running tests, I
am doing deployments, and all that other stuff, and yes one can survive
with a Chromebook doing that.

I've been using my [2015 HP chromebook 14](https://www.google.com/chrome/devices/hp-chromebook-14/)
in summer 2015 for like 3-4 months developping medium-large size Ruby on Rails application
for the company I was working for during that time.
*To be honest I was not using Chromebook all the time*. Usually I worked
3 days a week from home during that time I was using chromebook most of
the time. Remaining 2 days in the office I was developing on a work
computer.

Reason why I stopped using Chromebook was due
to keyboard fauthy on chrombook. One thing to remmember is that chromebooks
are cheap so simetimes the hardware suffers due to the price.

The biggest mind shift is that it's no longer the computing power of the
laptop in your hands doing that but the VM you are connected to.

## The new age of terminals

Before we go deeper let me present the stage (or just skip this section)

In the old days there was no such thing as having a huge computer power
at your hands. Everyone was connecting via they terminals to a huge
computer that was doing the work remmotly for them. Then came the era of Personal
Computers where each person had computer power at their desks. Now we
are in the era where nearly every web-developer has a shiny `i7` MacBook with
SSD drive, where tests are running blazing fast and we connect to remote
computer only if server is down and we need to debug.

if you are a web-developer and not a linux server sys-admin or
DevOps guy it kinda feels that the era of Terminals is long gone. Well in my opinion
it was just replaced by era of Cloud.

Think about it:

* we store all our assets and documents on Dropbox or Google Drive
* yes we run the tests on our laptops but we also run them
on a CI tools like [CodeShip](http://codeship.com/),
[TravisCI](https://travis-ci.com/), [Circle cI](https://circleci.com/)
* lot of time we don't need to dig around with Git commands to merge our code changes, we just use Github web interface
* we no longer ssh to the servers to do the deployment we configure our
[Github webhooks](https://developer.github.com/webhooks/) to trigger
builds for us.
* we no longer have to configure our entire Server Rack
ourself we push applications to Cloud hostings like
[Heroku](www.heroku.com), [DigitalOcean](https://www.digitalocean.com).
* (In some cases) we no longer write server shell scripts,
we configure web interface tools like [Jenkins](https://jenkins-ci.org/)  to do stuff
for us.
* our Docker images get automatically build by the Docker Registry
  itself by pulling content from Github ([DockerHub](https://docs.docker.com/docker-hub/builds/),
[Quay.io](https://quay.io) )
* are email / comunication tools has web interface (Slack, Gmail,
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

| Google "Cloude IDE" and you'll get more

Cloud9 and Codeanywhere appeard to me really simillar. They have wider
range of pricing (therefore you can have a cheeper plan) than
koding.com.

For me Cloud9 and Codeanywhere feels more IDE focused and Pair programing
focused (https://blog.codeanywhere.com/share-links-pair-programming/, https://www.youtube.com/watch?v=RLKEaMs1p10),
accesibility focused (codeanywhere has a mobile app, so you can
seriously code anywhere `:)` ) and Koding.com was giving you bigger VM and
for some reason the web interface is faster on a crapy network.

Unfortunatelly I cannot give you much feedback on the IDE experience as I'm a
**Vim** user and I didn't spend much time in the provided IDE. Also I didn't
convince my covorkers to try any of the cloud IDE tools I have no
feedback on the pairprograming features either. Hovever as it is with
any web-application software, they rapidly evolve features so I highly
recommend to just play around and get the feeling yourself. All 3 (and
also other) cloud IDE providers provide Free plan to play around the
only catch is that you need to shut them down and lunch them back up
after while. You don't have to buy a chromebook to try them out.

In the end I end up with Koding.com paid plan for couple of weeks and I
was just using Vim editor for editing code. The only big problem for any Vim
user on a Chromebook will be the infamous `Ctrl+w` shotcut is configured
to close browser tab. There is no way to change this, the only
workaround is either to remap split screan switch to other key combination or
just use `Alt+Ctrl+w` which is basically the same thing by default.

The VM provided in all three of these cloud IDE providers was fast
enough to run tests, in some casese the tests were actually faster on
the VM (1 core) than my work laptop (intel i5 4th gen). Think about it
VM's are in a serveroom with air-conditioning. You are sometimes running
your tests while sitting in a couch with your laptop on your lap
listening to music, with 50 firefox tabs open and mining bitcoins.

I was running "local" Ruby on Rails development server and using the
public DNS url of the Koding VM to access it, so it felt like I'm
working on a real laptop.

So that I comply with strict securrity policy of my company I've ended up actually
conecting from koding.com VM via encrypted ssh key to external VM (AWS EC2 micro instance)
where I had the code & ssh keys to connect to other servers and so on.
From here I was doing all the magic, developing code, running tests,
scheduling deployment, ssh to other servers when stuff went down.

## SSH for hard-core linux/vim/emacs audience

After a while I realized I don't need Web-Interface to connect to this AWS EC2 micro instance VM.
Chromebook has a extension SSH tool [Secure Shell](https://chrome.google.com/webstore/search/ssh)

| [AWS EC2 micro instance](https://aws.amazon.com/ec2/instance-types/) is eligable for
| [AWS free tier](https://aws.amazon.com/free/), so if you do your math correctly on provided resources
| you'll end up not paying a dime

All you have to do is to [generate ssh
keys](https://help.github.com/articles/generating-ssh-keys/) on some laptop or VM,
and copy the private key to Chromebook downloads folder. Then when you are
creating new connection in Chomebook Secure Shel extension, tell it to
use this key. Chromebook will then store this priate key in some folder
outside Downloads folder, so then you can delete from Downloads folder.

| Remember kids, having a password on a server is irresponsible and
| stupid. Always prefer the SSH key connection.

The development process was exactly the same as I described in previous
section. I was writing code via a Vim, running tests on a VM, doing
deploymennts([Capistrano](http://capistranorb.com/)) no problemo.
I was running development Rails server and
connecting via AWS EC2 instance public DNS address or IP + port.

Everything worked like a charm, therefore I've unsuscribed form the
Koding.com paid plan and just had it as a backup in case my flat is
robbed and all my laptops are stolen and I need to do a fix from a
non-configured PC ;) .

## UX and Design

And then one day comes where you need to some wireframes for a client.
Are you using tools like Adobe Fireworks and Adobe Photoshop on a daily
base? Do you deliver website designs, templates, assets on daily base ?
Well I wont be helpfull with that.

But If you're creating black/white/grey wireframes check online tool [UX
pin](https://www.uxpin.com/). If you are UX guy and newer tried it you would
be suprise how much you can do with a online tool. As a Linux guy
with lack of software options I've
use to use it way before my Chromebook experiment. It's really
comprehensive UX tool.

If you need to resize an image that a clumsy designer sent you in
wrong size, or you need to do some simple css sprice or image alteration for which
[Gimp](https://www.gimp.org/) would be good enough check out [Pixlr](https://pixlr.com).
Pixlr is a online Photoshop wanabe that contains lot of features (yes
layers included). You can can install Chrome extension for Pixlr that will give you bit better
usable interface.

## Holiday and Apocalypse  concern

Let say you are a Lead Web Developer or a DevOps person and you want to
go on a holiday. Your boss ask's you if you can bring your laptop with
you in case they have an unsolvable problem with server. You know just
in case. Because you are profesionnal you will say no problem and pack
your $2000 i7 MacBook Profesional with custom component build with you.

Now you come to the check in to the hotel and you want to store your
precious Laptop in a save. Yet you discover the safe is 7 by 10 inch
tall and you cannot fit your precious expensive laptop. What will you do
? Shell you leave it under the bed? Hidden amongs towels in the wardrobe ?
Will you go to the reception and place it in a hotel safe ?

And most importantly, will you actually enjoy the holiday thinking about
weather your laptop is still there ?

Ok another scenario. You know on friday you are invited to Metalcore
concert and there will be definitelly a great [mosh pit](https://www.youtube.com/watch?v=73d8pMnMbKg).
Now you wont be able to keep your laptop in the office due to some made
up reason. Would you take $300 Chromebook or $2000
MacBook to the office that day ?

I'm a huge fan of idea that the best laptop backup ist the one you never have
to do; store stuff in the cloud, in git repo, in remote server and you
don't have to wory about what will happen if ....

Chromebook is build on top of that philosophy.

## What if I don't have internet ?

I'm mainly focusing this article for web-developers and all good
web-developers introduce changes only if they have metrics to prove their point.
How many times lastmonth you were in a situation you had no internet in your office ?
...ok how about at home ?

Let say you are on Airport and you want to write some code. Have you got
your 4G Iphone or Android phone with you ? Cool press the HotSpot button.

If you like to code in a coffee shop or library there is always WiFi
(just always use secure VPN connection  more on that in topic below on security)

If you're saying: "but I want to write a code in a tube on my way home",
seriously how many times you done that past month in a crowded tube? You
know you're usually watching some screencasts on the phone
or listening some podcasts.

## Security

Chromebook by very definition is secure ([Chromebook security](https://support.google.com/chromebook/answer/3438631?hl=en-GB)).
You don't store files, 99% of everything you open is opend on a cloud
provider (probably with antivirus) like Gmail, Google Drive, Dropbox.
Only application that can be installed are Browser application for
Chrome.

Only thing from a security prespective that you need to be worried about
is wheather your internet connection is secure. Yes we all have `https`
websites but even that stuff can be hacked and you would be supprised
how many websites are misconfigured to send your cookie even if accesed
from `http` That's the sys-adming dude is so paranoid each time you are
mentioning that "you will be working from coffee place down the road
next Tuesday".

When you want to connect to public WiFi always connect via [VPN
connection](http://www.howtogeek.com/133680/htg-explains-what-is-a-vpn/).
Don't be cheap there is no good free solution that you can trust (unless
your company has a VPN of their own). You can get really secure
and good comertial VPN for like $10 a month and yes chromebook has really easy way
to set it up([How to set up VPN in chromebook](https://support.google.com/chromebook/answer/1282338?hl=en-GB).
I'm using [TorGuard VPN](https://torguard.net/)  (no, it
has nothing to do with Tor network)

Then comes to VM security that you are conecting too. Just fallow any
good practices that you would normally fallow for a web-app server. If
you are new to servers basic rules are keep your system up to date with
latest fixes, connect to VM via ssh key-pair not password, and don't
open ports you necesary have to. You will probably survive first year
with just SSH port and port 80 on your VM.

## Famous last words

My previous company was security crazy to be honest. We couldn't use lot
of tools that were on the market. We had our own Jenkins CI our own
servers our own everything except Github. The chances  are you are
working in more enlight enviromnet where you guys are using TravisCI or
CodeShip or DockerHub automated image builds and therefore you have all
those cool automated 3rd party tools with you.

I've survid working on a Chromebook I'll bet you will too.

Now do I recommend you to  buy a chromebook ? Absolutely not


Only limitation is Docker

