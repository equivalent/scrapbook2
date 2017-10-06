# Deep dive to Cloud coding part 2

This is 2nd part of article
http://www.eq8.eu/blogs/43-deep-dive-to-cloud-coding This was extracted
out as the article was getting too long.


To put the following recommendations to context I'm mostly Ruby on Rails developer.
I worked with Cloud Coding on a Social network app and commerce dashboard apps. The apps were not of size of
Facebook but still reasonably big. Like medium large. Most of the time projects were Monolith
with few microservices now and then. The experience may differ if you are
on larger / smaller project.

## Costs

Well as for the the Cloud IDE pricing you can find that on their websites :) .
But I'll give you some tips around what to look for.

> Sorry I honestly give you direct recommendation as  I use to use
> koding.com as it was the cheapest for the provided VM but they've changed their pricing and product model so I don't know now.
> Like I've said now days I like Codeanywhere.com as is free (or like $2) and you can plug your
> own VM. So this way you will pay only for VM.
>
> So for Cloud IDE solutions you will have to do some research.

In practice you have 2 options. Either you stick with their VMs or you plug
your own VM. In both cases the price will be similar but there may
security or skills concerns why you might want one or the other.

Some Cloud IDE provided VMs provide "buckets" which are preconfigured
VMs for given problem you want to solve. So for example if you are a
contractor jumping from project to project you don't want to spend too
much time configuring new VM from scratch. Here you just choose the
"solution" and work on it in mather of few minutes. This is also helpful
if you are Junior developer and you have no idea what you're doing.

> It quite feels like Digital Ocean "dropplets" or AWS ElasticBeanstalk


If you are working on more long term project I would recommend plugging
your own VM.

##### Own VM

This section apply both if you choos to plug VM to Cloud IDE or just do
Cloud Coding with SSH & Vim

It may be that your company has good deal with some cloud VM provider and so the company has extra VMs
available. So just discuss this with your boss and boom you have devel
machine without money going out of your pocket. Of course you need to
consider that that VM belongs to the company => good bye personal
projects.

And if you decide to plug your personal own VM, well nothing is for free. But if you
are clever about it and you are discipline enough to spin the VM down
when you not working on it and spin it back up when you need it, then
the costs should  should be fine.

I use personal [AWS EC2](https://aws.amazon.com/ec2/) [T2 small instance](https://aws.amazon.com/ec2/instance-types/).
 I launch it in the morning with AWS CLI `aws ec2
start-instances --instance-ids i-04xxxxxxxxxxxxxxx` and shut it down
in the evening with `aws ec2 stop-instances --instance-ids i-04xxxxxxxxxxxxxxx`

This way I'm paying like $10 - $20 per month. But if I forgot and kept it on
for long time (e.g. I'll go for holiday) then my bill will raise.

But if you just want to try Cloud Coding really cheap I recommend to check out [AWS EC2 Nano instance](https://aws.amazon.com/about-aws/whats-new/2015/12/introducing-t2-nano-the-smallest-lowest-cost-amazon-ec2-instance/).
This you can leave always on and it will be like
$6 per month. It's not that bad compared to buying $1000 Macbook every year. With nano instance you will not be able to
do much but  for small personal projects / open source libraries it should be
enough.

If you want to have heavy duty development instance on all the time and you are not afraid to set up VMs firewal
I recommend checking
[Linode VMs](https://www.linode.com/pricing?gclid=CjwKCAjw3rfOBRBJEiwAam-GsIM8TYsuxFSJZrWJQsdpWjQyuRB9wFpwz7zdHIF1Mo-fN2v67spYvRoC9EcQAvD_BwE) as
the prices are much cheaper for better power.

Again go with your skills your experiences don't just blindly use what
I'm using :).


#### Conclusion

During last few years Cloud Coding was costing me between $6 - $20 a
month. If you choose Cloud IDE it may be bit more but if you don't know Vim it will be worth it.
It always depended on if you going to write small projects (less memory
& CPU required) or large projects or projects with heavy technologies
(e.g. For Java, Docker or ElasticSearch based projects you will need
more resources)

## Power

I've notice that even on EC2 T2 micro instance (that's
like single core 1GB memory) the tests were faster than on my Intel i5
laptop (more on this [here](http://www.eq8.eu/blogs/18-chromebook-for-web-developers))

This really depends on how your application is set up and I don't have
any benchmarks to prove my point. It really just depends on what type of
project you are working on. But in practice your laptop is given day
consuming lot of memory and CPU around your Web browser, email client,
..., while VM is in cold server room executing one job. So it's a
thinker.


So you should be fine. If not just spin a VM with extra CPU core ;).

> For example in AWS EC2 you can create T2 nano instance with 1 CPU and 500 MB
> memory, later on you'll find out
> that your project needs 2 CPU and 2GB RAM. No problem, just change the
> instance type to T2 small and all your data will be in place. It's not like you need to buy a new Laptop
> each time your project grows.

## Security Concern

Cloud IDEs are reasonably secure enough if you are a regular developer that don't have production database dump
or  production server SSH keys on their box. Usually developers has on devel VM/laptop only 
"development" tokens that cannot do much harm to the company if they are stolen.
As Cloud IDE are browser based solutions I definitely recommend solution that is enabling you to do two
factor authentication.

For small side projects it's fine to use VM provided by Cloud IDE
solution, for professional software development I would recommend to always plug own VM (or company can always spare micro EC2 instance for 8 hours for sake of security)

However if you are the person who has authority to wipe out entire
database and all the backups then I would think twice about Cloud IDE.

The issue with Cloud IDEs is that even if you connect your own VM you need to allow range of IPs that will be able to ssh
to your VM [here](http://docs.codeanywhere.com/connections/sshserver.html)).

But if you have no idea how to configure Linux or AWS firewall then you
are screwed anyway and go with Cloud IDE VM.

> Never ever open connection to entire world by exposing SSH port to `0.0.0.0/0` or `::/0` !

Some employers will not even allow you to do this kind of approach as
their company need to have ISO accreditation and giving access to your environment
3rd party solution is by definition not secure in this industry.

But Cloud IDE or SSH + Vim always use VPN connection for extra level of
security.

HTTPS is reasonably secure enough but developers make mistakes.
There are multiple ways how session can be stolen if developer makes a
mistake in configuration. That's why modern browsers don't allow partial
http calls when main page is https.

But if you feel like it's a good idea to connect to Cloud IDE on a
public WiFi without VPN connection:

![Just don't do that](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2017/i-dare-you.jpg)

... then don't try Cloud Coding but
rather spend next few days reading upon
internet security.


You can check with your SysAdmin if your company has some already
existing VPN server and connect to that for free.

Go and investigate some commercial VPN providers. I can recommend [Torguard](Torguard.net) (no it has nothing to do with TOR network, they just choose stupid name for company)
or HideMyAss VPN. But be careful HideMyAss keeps traffic logs where as
Torguard states they don't. You don't have to care about that if you
just need it for Web development but if you want to download occasional
torrent file then you are on their radar. But I'm not engaging anyone to
no such activities, just providing an example :)

If you decide other VPN provider then check their background. Where is
the company located, who owns them, read up on independent reviews.

> If you discover VPN for $2 based in China it may not be good idea !


Also: **never ever ever  ever ever ever ever ever ever go via Free VPN or TOR !!!!**


Using VPN means you literally are on the network connection of the sever
where you are connected. That means if that free VPN server is a  hacker machine sniffing
traffic you are throwing away your access keys.


You may not need VPN when you are connected via ethernet plug (RJ45) and
that's ok.

But if your router is then transmitting the signal via air (WiFi) and
say "I'm 100% secure even without VPN" then
you are an idiot.


## I like going security nuts

So personally I rather prefer SSH to VM and launch Vim or Tmux there and
not to use Cloud IDE. I'm also connected to a VPN for extra level of
security when I'm on WiFi. It's highly improbable but not impossible to
break SSL only connection (Again I'm nuts in these things)

I'm personally using AWS EC2 instance for my remote coding. I'm only
allowing one ssh connection and one https connection from current laptop
IP and remove old IP address (Script: [AWS CLI add current IP to security group](https://gist.github.com/equivalent/b065dac71316b815fa98fafa0684dc85) )

I'm not ever allowing port 80 (http connection), just ssh port 22 and 443 for https.
Again this is always allowed only from current laptop IP.

You just need to be sure you are able to configure NginX to proxy to
your app server and you know how to generate self signed
certificate ( [like this](https://github.com/equivalent/scrapbook2/blob/master/nginx.md) )

> in reality I'm not allowing port 22 for ssh but different port. But
> that's a secret ;)

Then when I'm not working with the VM I'm just turning it off with a
script, and in the morning turning it on. This way I'll save money (as
EC2 instance is paid by hours on) and
don't have to be worried about security.

One more thing EC2 instance comes with non encrypted drive. That's why
I'm mounting another EBS Volume that is entirely encrypted. I have the
development DB the ssh key, token, git repos and anything related to secrets there. I only decrypt &
mount it in the morning.

 It's not bulletproof safe but at least some level of
security when breach occurs.


