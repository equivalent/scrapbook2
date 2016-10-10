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


![step 1](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/cloudflare-aws-route-54_1.png)

![step 2](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/cloudflare-aws-route-54_2.png)

![step 3](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/cloudflare-aws-route-54_3.png)

![step 4](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/cloudflare-aws-route-54_4.png)

![step 5](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/cloudflare-aws-route-54_5.png)

![step 6](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/cloudflare-aws-route-54_6.png)
