# How to configure Route 53 to Cloudflare

[Cloudflare](https://www.cloudflare.com) is a DNS level CDN.
All you need to do is change your Domain name server to theirs and their
will take care of lot of caching and distribution.

The problem is that when you're using [AWS Route 53](https://aws.amazon.com/route53/) you may
notice that your Name servers get reset back to AWS ones in couple of
days.

This is due to fact that Route 53 has 2 places where you need to
configure NS.

Most of us configure the NS in "Hosted Zones"

But you also need to go to your Registered Domains, click the domain you want to
modify, and then Add/Edit the name servers there.

> Article is based on solution http://serverfault.com/a/704577 . Thanks
> [Oblio](http://serverfault.com/users/133223/oblio) ! 



