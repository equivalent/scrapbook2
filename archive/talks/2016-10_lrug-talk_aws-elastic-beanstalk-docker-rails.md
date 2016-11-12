# AWS Elastic Beanstalk & Docker for Rails developers

Elastic Beanstalk (EB) is a product from Amazon Web Services (AWS)
that is helps you to setup
and maintain your EC2 instances (VMs) under load-balanced environment with
many of the security, auto-scaling and monitoring configuration done for
you.

In this talk I will quickly explain choices that you have when you
are dealing with application under [Docker](https://www.docker.com/what-docker)
environment  and show you how to set up your infrastructure for
your application in a way that is both AWS and Docker good practice
using AWS Elastic Beanstalk, and then we will look at some awesome
configuration options of EB.

Our [example AWS EB application](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app)
is developed with Ruby on Rails, but because we are dealing with Docker
you can replicate the steps with any language.

## Talk assets:


* [Talk Slides](https://docs.google.com/presentation/d/14XwwfX4348fj6mglEo4gksioSDHW00MFN4iB9_-H4KY/edit#slide=id.gffdf33b32_1_60) (mirror: bit.ly://aws-eb-slides)
* [Demo Application](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app) - source code, `docker-composer.yml`, `Dockerrun.aws.json conf`, ... (mirror: bit.ly://aws-eb-source)


http://bit.ly/aws-eb-app

* [How to create new ElasticBeanstalk environment](http://www.eq8.eu/blogs/34-set-up-aws-elastic-beanstalk) ([MIRROR source](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2016-11-set-up-aws-elastic-beanstalk-demo.md))


* [How to create new ElasticBeanstalk environment SLIDES](https://docs.google.com/presentation/d/1cMx3SL6cfQy-oKDgxLprpgPTBjOG4gN-F8AXDgP-3Tc/edit?usp=sharing)



http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/Welcome.html
