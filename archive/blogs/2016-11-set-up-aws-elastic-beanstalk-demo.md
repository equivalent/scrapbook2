# Set up AWS Elastic Beanstalk

This article is related to talk I gave 15th of November 2016 at LRUG
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

![RDS settup 1](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3100.png)
![RDS settup 2](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3200.png)
![RDS settup 3](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3400.png)
![RDS settup 4](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3500.png)
![RDS settup 5](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3600.png)
![RDS settup 6](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-3700.png)

Later on we will use this "Endpoint URL"  via Enviroment
Variables `ENV['REL_DATABASE_HOST']` in our Rails app.

![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-4100.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-4200.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-4400.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5100.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5200.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5300.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5400.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5500.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5600.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5650.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5700.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5800.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5900.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5910.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5920.png)
![ ](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/eb-demo/eb-demo-5930.png)

