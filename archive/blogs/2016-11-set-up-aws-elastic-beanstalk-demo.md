# Set up AWS Elastic Beanstalk

This article is related to [talk](http://www.eq8.eu/talks/2-aws-elastic-beanstalk-docker-for-rails-developers) I gave 15th of November 2016 at LRUG
(CodeNode Skills Matters London)

It will show you how to set up AWS products for demo application which
source code can be found here: [https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app)

![Lading page](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-0000.png)

Create an account and Log in to https://aws.amazon.com/

## Step 1 - Generate SSH key

Go to EC2 product and generate SSH private key via EC2 Key Pair tool.
This will be need for our EC2 instances once they are runnig so that we
can SSH to them.

![Generate ssh key via Key Pair tool 1](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-1100.png)
![Generate ssh key via Key Pair tool 2](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-1200.png)
![Generate ssh key via Key Pair tool 3](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-1300.png)

Be sure to save the ssh private key (`Puppies.pem`) to a sefe place. You
will need it in a futer to ssh to the servers.

## Step 2 - Step 2 - Testing Security Group

This step is optional if you know what you are doing.

AWS Security Groups are basically firewall rules that disable everything by default.
We will create a Dummy Testing Security Group called "test-liberal" to allow all ports from all IPs (just for Demo)

> Now please be sure you you set up correct firewall rules for a real
> app once you're done.
> (e.g. only inbound ports that are needed for given service, ssh only from your IP, ...)

![Security Groups](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-2100.png)

## Step 3 - Create RDS database

Now we will set up our PostgreSQL database via AWS RDS product.

![RDS setup 1](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3100.png)
![RDS setup 2](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3200.png)
![RDS setup 3](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3400.png)

Choos database username, password and instance type.

We are choosing micro instance as it's cheaper, but if you are doing
this for a real product I would recommend `m3.medium` for medium size
project.

You can read about different types of instances here https://aws.amazon.com/ec2/instance-types/

![RDS setup 4](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3500.png)

Be sure o use our `test-liberal` security group.

![RDS setup 5](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3600.png)
![RDS setup 6](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3700.png)

Later on we will use this "Endpoint URL"  via Enviroment
Variables `ENV['REL_DATABASE_HOST']` in our Rails app.

## Step 4 - Create ElasticCache Redis cluster

Same as in RDS setup be sure to use our `test-liberal` security group
and we will use the endpoint url as `ENV['REDIS_HOST']`.

![ES setup 1](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-4100.png)
![ES setup 2](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-4200.png)
![ES setup 3](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-4400.png)

## Step 5 - Create ElasticBeanstalk Environment

![AWS EB setup 01](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5100.png)
![AWS EB setup 02](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5200.png)

We want to use WebServer Environment.

> In our demo app even the BG worker
> Docker container will be running as part of it. Feel free to extract BG
> worker to own environment if you choose so.

![AWS EB setup 03](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5300.png)

We want to demonstrate the loadbalanced enviroment -> we can introduce
more EC2 instances if load is higher.

![AWS EB setup 04](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5400.png)

You can use "Sample Application" which is just a Dummy Application from
AWS EleasticBeanstalk. But you can choose to upload the `Dockerrun.aws.json` to it
which will basically deploy or [demmo application](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app)

![AWS EB setup 05](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5500.png)

In future you can point your real domain (e.g. www.pupies.com) to this
elastic beanstalk URL via CNAME rule.

![AWS EB setup 06](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5600.png)

You don't need to create RDS, we just done it in prev. step.

![AWS EB setup 07](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5650.png)

Choose our key pair from step 1. ElasitcBeanstalk will configure EC2
instances so that all current and even newly introduced will have our
SSH Key.

Health Check is also important. Be sure to pint it to url that responds
with non error status code (so something that responds 200). this is
needed as LoadBalancer will not direct responses to your EC2 instance if
they are not "healthy" (if they don't respond to healthcheck endpoint
requests)

> For the demo application be sure you choose at least m3.medium or t2.medium instance,
> otherwise you may not have enough memory on your instance.

![AWS EB setup 08](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5700.png)

Tags are just for you. No need to fill them.
![AWS EB setup 09](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5800.png)

You can leave the Permissions on whatever EB sets by default.
![AWS EB setup 10](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5900.png)

So one more time check if your setup is correct. As we can see we are
introducing Multicontainer Docker, EC2 instances in load balanced enviroment.

![AWS EB setup 11](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5910.png)

Environment creation will take some time
![AWS EB setup 12](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5920.png)

But once done our application should be accessible from Elasticbeanstalk URL
![AWS EB setup 13](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5930.png)



## Related Articles

* http://www.eq8.eu/blogs/25-common-aws-elastic-beanstalk-docker-issues-and-solutions
* http://www.eq8.eu/blogs/29-aws-elasticbeanstalk-deployment-hooks
