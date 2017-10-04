# Deep dive to Cloud coding part 2


## Pricing and power

Well the Cloud IDE pricing you can find on their websites. I use to use
koding.com but they changed their pricing and product model so I don't know now.

Like I've said now days I like Codeanywhere.com as is free (or like $2) and you can plug your
own VM. So this way you will pay only for VM.

As for development VM:

Well nothing is for free especially if you are running VMs. But if you
are clever about it and you are discipline enough to spin the VM down
when you not working on it and spin it back up when you need it you
should be fine.

I use [AWS EC2](https://aws.amazon.com/ec2/) [T2 small instance](https://aws.amazon.com/ec2/instance-types/).
 I lunch it in the morning with AWS CLI `aws ec2
start-instances --instance-ids i-04xxxxxxxxxxxxxxx` and shut it down
in the evening with `aws ec2 stop-instances --instance-ids i-04xxxxxxxxxxxxxxx`

This way I'm paying like $20 per month. But if I forgot and kept it on
for long time (e.g. I'll go for holiday) then my bill will raise.

But if you just want to try Cloud coding really cheap I recommend to check out [AWS EC2 Nano instance](https://aws.amazon.com/about-aws/whats-new/2015/12/introducing-t2-nano-the-smallest-lowest-cost-amazon-ec2-instance/).
This you can leave always on and it will be like
$6 per month. It's not that bad compared to buying $1000 Macbook every year. With nano instance you will not be able to
do much but at least for small personal projects / libraries should be
enough.

If you want to have heavy duty development instance on all the time and you are not afraid to set up VMs firewal
I recommend checking
[Linode VMs](https://www.linode.com/pricing?gclid=CjwKCAjw3rfOBRBJEiwAam-GsIM8TYsuxFSJZrWJQsdpWjQyuRB9wFpwz7zdHIF1Mo-fN2v67spYvRoC9EcQAvD_BwE) as
the prices are much cheaper for better power.

Again go with your skills your experiences don't just blindly use what
I'm using :).

As for the power I've notice that even on EC2 T2 micro instance (that's
like single core 1GB memory) the tests were faster than on my Intel i5
laptop (more on this [here](http://www.eq8.eu/blogs/18-chromebook-for-web-developers))

This really depends on how your application is set up and I don't have
any benchmarks to prove my point. It really just depends on what type of
project you are working on. But in practice your laptop is given day
consuming lot of memory and CPU around your Web browser, email client,
..., while VM is in cold server room executing one job. So it's a
thinker.



## Security Concern

Cloud IDEs are reasonably secure enough if you are a regular developer that don't have production database clone
or access to prod server ssh keys and on your VM you only have
"development" tokens that cannot do much harm to the company. As this are browser based
solutions I definitely recommend solution that is enabling you to do two
factor authentication.

For small personal projects it's fine to use VM provided by Cloud IDE
solution, for professional software development I would recommend to always plug own VM (or company can always spare micro EC2 instance for 8 hours for sake of security)

However if you are the person who has authority to wipe out entire
database and all the backups then I would think twice about Cloud IDE.

The issue with Cloud IDEs is that even if you connect your own VM you need to allow range of IPs that will be able to ssh
to your VM [here](http://docs.codeanywhere.com/connections/sshserver.html)).

> Never ever open connection to entire world by exposing ssh port to `0.0.0.0/0` or `::/0` !

Some employers will not even allow you to do this kind of approach as
their company need to have ISO accreditation and giving access to your environment
3rd party solution if by definition not secure in this world.


## I like going security nuts

So personally I rather prefer ssh to VM and lunch Vim or Tmux there and
not to use Cloud IDE. I'm also connected to a VPN for extra level of
security when I'm on WiFi. It's highly improbable but not impossible to
break ssl only connection (Again I'm nuts in these things)

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
development DB the ssh key, token, git repo there. I only decrypt &
mount it in the morning. It's not super safe but at least some level of
security when breach occurs.




