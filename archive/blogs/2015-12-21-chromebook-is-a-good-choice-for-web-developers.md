# Chromebook is a good choice for web developers

Now this may sound stupid but It's true. 

I'm not just talking about some basic frontend debugging, I'm not
just talking about some JavaScript frontend framework development or
ChromeApp development. I'm not even talking about reinstalling Linux on a Chromebook or running
[Crouton](https://github.com/dnschneid/crouton) environment, or some
weird expensive Chromebook.

No Sir (...or Madam ) I'm talking about writing WebApp backend code,
running tests, deploying the app from a band new $200 - $300 Chromebook.


There are already some articles on experience that Web-Developers had
developing code on Chromebooks:

* https://divshot.com/blog/tips/using-a-chromebook-for-web-development/
* https://medium.com/@martinmalinda/ultimate-guide-for-web-development-on-chromebook-part-1-crouton-2ec2e6bb2a2d#.r7bn4vqpx
* https://medium.com/@martinmalinda/ultimate-guide-for-web-development-on-chromebook-part-1-crouton-2ec2e6bb2a2d#.r7bn4vqpx

...I just though I'll bring to comunity another article with my experience.


If anyone red my previous blog posts before they may know that I'm a Full Stack Ruby on Rails
Developer. I daily write tones of code on both Backend & Frontend side +
butload of DevOps. I'm a huge proponent of testing, TDD, BDD, CI tools.
I even do some level of UX design, wireframing + some
level of design alterations (we call those people Photoshop guys)

The reason why I'm mentioning all of this is to present a view that on
daily base I am working with servers, I am writing and running tests, I
am doing deployments, and all that other stuff, and yes one can survive
with a Chromebook doing that.

I've been using my [2015 HP chromebook 14](https://www.google.com/chrome/devices/hp-chromebook-14/)
in 2015 for like 3-4 months developping medium-large size Ruby on Rails application
for the company I was working for during that time.
*To be honest I was not using Chromebook all the time*. Usually I worked
3 days a week from home during that time I was using chromebook most of
the time. Remaining 2 days in the office I was developing on a work
computer.

Reason why I stopped using Chromebook was due
to keyboard fauthy on chrombook. One thing to remmember is that chromebooks
are cheap so simetimes the hardware suffers due to price.

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

* we store all our assets on Dropbox or Google Drive
* yes we run the tests on our laptops but we also run them
on a CI tools like [CodeShip](http://codeship.com/),
[TravisCI](https://travis-ci.com/), [Circle cI](https://circleci.com/)
* we no longer ssh to the servers to do the deployment we configure our
[Github webhooks](https://developer.github.com/webhooks/) to trigger
builds for us.
* we no longer have to configure our entire Server Rack
ourself we push applications to Cloud hostings like
[Heroku](www.heroku.com), [DigitalOcean](https://www.digitalocean.com).
* (In some cases) we no longer write server shell scripts,
we configure tools like [Jenkins](https://jenkins-ci.org/)  to do stuff
for us.
* our Docker images get automatically build by the Docker Registry
  itself by pulling content from Github ([DockerHub](https://docs.docker.com/docker-hub/builds/),
[Quay.io](https://quay.io) )
* Even our personal holiday photos are on Google photos or Flicker

## IDE in the Cloud

Last few year I'm witnessing raise of several "Cloud IDEs". They
basically provide a web interface editor and usually a small VM to do
your development and run the tests, or you can connect your VM.

I've personally tried:

* [cloud9](https://c9.io/),
* [codeanywhere](https://codeanywhere.com/)
* [koding.com](https://koding.com/)

Google "Cloude IDE" and you'll get more

Cloud9 and Codeanywhere appeard to me really simillar. They have wider
range of pricing (therefore you can have a cheeper plan) than
koding.com.

For me Cloud9 and Codeanywhere were more IDE focused and Pair programing
focused (https://blog.codeanywhere.com/share-links-pair-programming/, https://www.youtube.com/watch?v=RLKEaMs1p10),
accesibility focused (codeanywhere has a mobile app actually so you can
really code anywhere `:)` ) and Koding.com was giving you bigger VM and
for some reason the web interface is faster on a crapy network.

Unfortunatelly I cannot give you much feedback on the IDE experience as I'm a
**Vim** user and didn't spend much time in the provided IDE. Also I didn't
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
workaround is either to remap switch split screat to other key combination or
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
deploymennts no problemo. I was running development Rails server and
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
be suprise how much you can do with this online tool. As a Linux guy
with lack of software options I
use to use it way before my Chromebook experiments it's really
comprehensive UX tool.

If you need to just resize an image that a clumsy designer sent you in
wrong size, or you need to do some image alteration for which
[Gimp](https://www.gimp.org/) would be good enough check out [Pixlr](https://pixlr.com).
You can can install Chrome extension for Pixlr that give you bit better
usable interface.

## Holiday and Apocalypse  concern

Let say you are a Lead Web Developer or a DevOps person and you want to
go on a holiday. Your boss ask's you if you can bring your laptop with
you in case they have an unsolvable problem with server. You know just
in case. Because you are profesionnal you will say no problem and pack
your $2000 i7 MacBook Profesional with custom component choise with you.

Now you come to the check in to the hotel and you want to store your
precious Laptop in a save. Yet you discover the safe is 7 by 10 inch
tall and you cannot fit your precious expensive laptop. What will you do
? Shell you leave it under the bed? Hidden amongs towels in a wardrobe ?
Will you go to the reception and place it in a hotel safe ?

And most importantly, will you actually enjoy the holiday thinking about
weather your laptop is still there ?

Ok another scenario. You are invited to a 

## Famous last words

My previous company was security crazy to be honest. We couldn't use lot
of tools that were on the market. We had our own Jenkins CI our own
servers our own everything except Github. The chances  are you are
working in more enlight enviromnet where you guys are using TravisCI or
CodeShip or DockerHub automated image builds and therefore you have all
those cool automated 3rd party tools with you.

I've survid working on a Chromebook I'll bet you will too.






Only limitation is Docker

