# AWS Lambda to configure EC2 Security Group for CloudFront access

Given I have restricted IP/SecurityGroup access LoadBalancer (or single EC2)
When I try to configure AWS CloudFront CDN to access it
Then I cannot as CloudFront don't have security groups

So there is no way to add CloudFront security group to Security Group of
a EC2 instance (or LoadBalancer).

This makes sense. CDN is public distribution system (yes there are cases
where this is not true but this is outside the scope of the article).
If you use CDN it's somewhat expected that your
EC2 instance / Load Balancer is `0.0.0.0` accessible for port `80` or
`443`

So if you are in a situation you have hidden EC2 instance / LB but the
assets (JS,CSS) can be public, the only way to enable the CloudFront CDN
access to your server is to add IP addresses to your instance/LB Security Group


Now if that sound like crazy idea here is source:

* https://forums.aws.amazon.com/thread.jspa?threadID=218019
* https://www.youtube.com/watch?v=gUAuhdtHacI

So one solution is to configure AWS Lambda scheduled periodically by
AWS CloudWatch to pull list of AWS IPs (from [here](https://ip-ranges.amazonaws.com/ip-ranges.json)) and add them to EC2/LB
SecurityGroup

> in [Reddit](https://www.reddit.com/r/aws/comments/6g4dm5/aws_lambda_to_configure_ec2_security_group_for/)
> discussion it was pointed out that this is "not secure". Yes it's not
> it depends how much you want your server hidden and how you configure
> your CloudFront distribution.
>
> You need to be sure your CF CDN is pointing origin only to assets
> folder (`/assets` or `/js` or `/css`) and not entire `/` as then the
> attacker can call your website via CDN
>
> If you want to create
> super secret government project that not even CSS can get away to public, then yes this is not a solution for you.
>
> But this solution (I'm using) is just for a staging server of a public service. I just want to hide the
> staging server so that it's not accessed by real users sending me emails
> "my password is not working", yet I want to keep the CloudFront
> configuration so that I can test similar production setup. I reccomend
> to read the [Reddit discussion](https://www.reddit.com/r/aws/comments/6g4dm5/aws_lambda_to_configure_ec2_security_group_for/)
>
> Think about business / security aspects before you copy paste

There is already good blog on how to do this:

https://spin.atomicobject.com/2016/03/01/aws-cloudfront-security-group-lambda/


...I recommend to follow it but I've found that the Python script needed some alteration to be
working:


```python
from __future__ import print_function

import json, urllib2, boto3


def lambda_handler(event, context):
    response = urllib2.urlopen('https://ip-ranges.amazonaws.com/ip-ranges.json')
    json_data = json.loads(response.read())
    new_ip_ranges = [ x['ip_prefix'] for x in json_data['prefixes'] if x['service'] == 'CLOUDFRONT' ]
    #print(new_ip_ranges)

    ec2 = boto3.resource('ec2')
    security_group = ec2.SecurityGroup('sg-6rrrrr10')
    current_ips = security_group.ip_permissions
    if len(current_ips) == 0:
        current_ip_ranges = []
    else:
        current_ip_ranges = [ x['cidrip'] for x in current_ips[0]['ipranges'] ]
   
    print(current_ip_ranges)

    params_dict = {
        u'PrefixListIds': [],
        u'FromPort': 80,
        u'IpRanges': [],
        u'ToPort': 443,
        u'IpProtocol': 'tcp',
        u'UserIdGroupPairs': []
    }

    authorize_dict = params_dict.copy()
    for ip in new_ip_ranges:
        if ip not in current_ip_ranges:
            authorize_dict['IpRanges'].append({u'CidrIp': ip})

    revoke_dict = params_dict.copy()
    for ip in current_ip_ranges:
        if ip not in new_ip_ranges:
            revoke_dict['IpRanges'].append({u'CidrIp': ip})

    print("the following new ip addresses will be added:")
    print(authorize_dict['IpRanges'])

    print("the following new ip addresses will be removed:")
    print(revoke_dict['IpRanges'])

    security_group.revoke_ingress(IpPermissions=[revoke_dict])

    security_group.authorize_ingress(IpPermissions=[authorize_dict])

    return {'authorized': authorize_dict, 'revoked': revoke_dict}
```

reference for changes: https://boto3.readthedocs.io/en/latest/reference/services/ec2.html#instance

> I don't know Python, so if you know how to write this better please
> submit PR, I'll be happy to merge it in.

## Entire flow

> again this is based entirely on 
> [JUSTIN KULESZA's blog](https://spin.atomicobject.com/2016/03/01/aws-cloudfront-security-group-lambda/) (all credits to him) I just want to have
> mirror T.I.L. here in case if the website ever dissapears or
> something.

Note: make sure you are configuring everything in one region!

### step 1 create custom security grop

Create new security grup where the Lambda will be sending the IPs. Make
sure no other Inbound rules are there as we will be deleting them with
the script.

Let say your security group is `sg-6rrrrr10`. For rest of the blog I'll
be referencing it.

Then assign this security group. If you using just EC2 instance and no
LoadBalancer, assign the SG to EC2 instance (If you use ElasticBeanstalk there is a option in instances configuration that will repricate to newly added instances).
 If you using LoadBalancer assign the
security group
to LoadBalancer

Load balancer example:

![](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2017/configure-load-balancer-access.png)

### step 2 create lambda

AWS Lambda > New Function > Blank Blueprint > 

![configure lamda](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2017/configure-lambda.png)

> notice that cloudfrant is trigering this every 1 hour

Inside Configure Function paste the Python script pasted above, choose
ENV Python 2.7 and create (and then assign to lambda) a security policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeNetworkAcls"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "arn:aws:ec2:eu-west-1:*:security-group/sg-6rrrrr10"
        }
    ]
}
```

> note that  Resource ARN is pointing to region `eu-west-1` change that
> to your need


That should be it. If something is not woring check if you by accident
not restricting  EC2 security groups to limit access instead of LB
security group.


### Aknowlegement

All credits to Justin Kulesza.
