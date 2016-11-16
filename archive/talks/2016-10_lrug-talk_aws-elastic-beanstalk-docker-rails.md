# AWS Elastic Beanstalk & Docker for Rails developers

Elastic Beanstalk (EB) is a product from Amazon Web Services (AWS)
that helps you to setup
and maintain your EC2 instances (VMs) under load-balanced environment with
many of security, auto-scaling and monitoring configuration done for
you.

In this talk I will quickly explain choices that you have when you
are dealing with application under [Docker](https://www.docker.com/what-docker)
environment  and show you how to set up your infrastructure for
your application in a way that is both AWS and Docker good practice.

We will then introduce AWS Elastic Beanstalk and look at some of its awesome
configuration options.

Our [example AWS EB application](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app)
is developed with Ruby on Rails, but because we are dealing with Docker
you can replicate the steps with any language.

## Talk assets:

* **>>> [Talk Video](https://skillsmatter.com/skillscasts/9280-aws-elastic-beanstalk-and-docker-for-rails-developers) <<<**
* [Talk Slides](https://docs.google.com/presentation/d/14XwwfX4348fj6mglEo4gksioSDHW00MFN4iB9_-H4KY/edit#slide=id.gffdf33b32_1_60)
* [Demo Application](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app) - source code, `docker-composer.yml`, `Dockerrun.aws.json conf`, ...

##### Set up new AWS EB environment:

* [How to create new ElasticBeanstalk environment Blog](http://www.eq8.eu/blogs/34-set-up-aws-elastic-beanstalk) ([MIRROR source](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2016-11-set-up-aws-elastic-beanstalk-demo.md))
* [How to create new ElasticBeanstalk environment SLIDES](https://docs.google.com/presentation/d/1cMx3SL6cfQy-oKDgxLprpgPTBjOG4gN-F8AXDgP-3Tc/edit?usp=sharing)

##### Pre-built application (puppies app) Docker images:

* https://hub.docker.com/r/equivalent/eb-demo-rails/
* https://hub.docker.com/r/equivalent/eb-demo-nginx/


##### Shorter Mirror links

```
| Subject          | Link                        |
|------------------|-----------------------------|
| root page        | http://bit.ly/aws-eb        |
| Talk Video       | http://bit.ly/aws-eb-talk   |
| Talk Slides      | http://bit.ly/aws-eb-slides |
| Demo Application | http://bit.ly/aws-eb-app    |
```

## Other Resources

* [Eq8 BLOG - Common AWS Elastic Beanstalk Docker issues and solutions](http://www.eq8.eu/blogs/25-common-aws-elastic-beanstalk-docker-issues-and-solutions)
* [Eq8 BLOG - Elastic Beanstalk deployment hooks](http://www.eq8.eu/blogs/29-aws-elasticbeanstalk-deployment-hooks)
* [Build Docker images on your machine or in the cloud ?](http://www.eq8.eu/blogs/17-build-docker-images-on-your-machine-or-in-the-cloud)
* http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/Welcome.html
* [Youtube - AWS Elastic Beanstalk and Docker by Evan Brown (AWS)](https://www.youtube.com/watch?v=OzLXj2W2Rss)
