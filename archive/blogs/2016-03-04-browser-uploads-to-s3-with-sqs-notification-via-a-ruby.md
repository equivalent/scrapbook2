# Browser upload directly to S3 and triggering SQS notification to your App

In this article we are going to configure direct browser upload to S3
bucket.

## step 1 - create S3 bucket

Go to [AWS Management Console (the aws
web-interface)](https://console.aws.amazon.com/s3/) and go to S3
section.

Click on the `Create Bucket` button, Name your bucket and choose
"region" that is best for you (closest server to your key market maybe ?)


I will create bucket `myappcom-documnets-ireland-development` and 
`myappcom-documnets-australia-development`


Keep this tab open we will do some configuration here in next steps.


## Step 2 - create user

Go to [AWS Management Console for Identity and Access
Management](https://console.aws.amazon.com/iam/) > Users >
 Create New User. 

Here create a user/s (e.g. `uploader_DEVEL` and `uploader_PROD`) and
copy his credentials (access key ID and Secret Access KEY). We will use
this credentials later. Once done `close`.


#### Step 3.1 - attach super policies

In the Users interface click on this user, and in the `Permissions`
section click on `Attach Policy` for debuging purpose select
`AmazonS3FullAccess` and `AmazonSQSFullAccess`. Click on `Attach Policy`
button.

Like I said this is just for Debugging. Once we test our S3 and SQS remember to change
these policies to less vulnerable like those in step below (3.2). **Don't
do that step now, but remember to return to it once finished with this
tutorial.**

#### Step 3.2 -proper policies (Advanced)

**Skip this step for now if you didn't finish other steps and you are new to AWS**

Here is an example of much stricter policies that I'm using. Make sure you
replace endpoints properly according to your setup.

Click on User > `Permissions` > `Inline Policies` and attach:

**For SQS**

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:sqs:ap-southeast-2:666666666666:myappcom-queue-australia-development",
                "arn:aws:sqs:eu-west-1:666666666666:myappcom-queue-ireland-development"
            ]
        }
    ]
}
```

**For S3**

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "Stmt1458818946000",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::myappcom-documnets-ireland-development",
                "arn:aws:s3:::myappcom-documnets-australia-development"
            ]
        }
    ]
}
```


##  Step 3 - create SQS

Go to AWS SQS section > create SQS

I'm going to create `myappcom-queue-ireland-development`

Once created click on it and click on `Permissions` > `edit policy
document`.

Here we are going to enable our bucket to write to this SQS Queue
events as well as our user `uploader_DEVEL` to read / delete form the Queue.

```json
{
  "Version": "2008-10-17",
  "Id": "example-ID",
  "Statement": [
    {
      "Sid": "example-statement-ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:eu-west-1:666666666666:myappcom-queue-ireland-development",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:*:*:myappcom-documnets-ireland-development"
        }
      }
    },
    {
      "Sid": "Sid1457107544131",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::666666666666:user/uploader_DEVEL"
      },
      "Action": "SQS:*",
      "Resource": "arn:aws:sqs:eu-west-1:666666666666:myappcom-queue-ireland-development"
    }
  ]
}
```


Now switch region to Asia Pacific (top right corner) and create another SQS queue for
Sidney similarly.

## Step 4 - Bucket configuration

Got that bucket tab still open ? Good return to it and do fallowing
config:

#### Step 4.1 - assign CORS to Bucket

In AWS Management Console for S3 (web-interface) click on your S3 bucket
and on the right side of the interface click on `Properties` >
 `Permissions` > `Edit CORS Configuration`.

CORS are permissions on a media storage. So think about it as a S3
Backend policy. It's really up to your business implementation what you
need there, here I'm just going to paste my configuration for read /
upload permission from particular server.

for Development bucket use setup similar to this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>http://127.0.0.1:3000</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
    <CORSRule>
        <AllowedOrigin>http://localhost:3000</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

for production


```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>https://www.myapp.com</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

##  Step 4.2 - set S3 bucket to send SQS notifications

Go back to AWS Management Console for S3, click on a bucket >  properties > `events`

* Name:  (can be anything really)
* Events : Object Created (all); so Put, Post, Copy,
  CompeleteMultipartUpload
* Prefix: can be empty, not important, up-to you, e.g.: `uploads/` or
  `browser-uploads`
* Send To: SQS queue
* SQS Queue: `myappcom-queue-ireland-development` (Queue, we created in
  prev. step)

Test this by uploading a file from the web interface into this bucket.
In SQS you can click on the Queue > Queue Actions > View/Delet Messages > Start
Pooling


## Ruby Part

Ok now we that we have the AWS part set up lets play around with Ruby
setup.

Install AWS SDK

```Ruby
# Gemfile
# ...
gem 'aws-sdk', '>= 2.0.0'
# ...
```

and run irb console

```ruby
require 'aws-sdk'

sqs = Aws::SQS::Client.new({
 region: 'eu-west-1',
 aws_access_key_id: 'AxxxxxxxxxxxxxxxA',
 aws_secret_access_key = 'zbxxxxxxxxxxxxxxxxxxxxxxxxxv'
})

# you can get queue endpoint in SQS web interface when you click on queue and `details`
queue_url = 'https://sqs.eu-west-1.amazonaws.com/666666666666/myappcom-queue-ireland-development'

sqs.receive_message(queue_url: queue_url)

messages  #  [ #<struct Aws::SQS::Types::ReceiveMessageResult]
```

You should be able to see queue endpoints, if so you can fetch the
messages.


As for the browser upload:

```ruby

a = Aws::S3::Bucket.new('pobble.com-browser-uploads-production', region:
'eu-west-1')





[AWS SDK V2 Presign post](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/PresignedPost.html)




sources:

* https://leonid.shevtsov.me/en/demystifying-s3-browser-upload
* [heroku s3 direct browser upload article](https://devcenter.heroku.com/articles/direct-to-s3-image-uploads-in-rails#example-app)
* [heroku article on how to get to S3 access](https://devcenter.heroku.com/articles/s3)
* [set S3 to notify AWS SQS permissions]( http://docs.aws.amazon.com/AmazonS3/latest/dev/ways-to-add-notification-config-to-bucket.html#step1-create-sqs-queue-for-notification)
* https://github.com/aws/aws-sdk-ruby/tree/aws-sdk-v1/samples/sqs
* [sns sqs after s3   upload](https://docs.aws.amazon.com/AmazonS3/latest/dev/ways-to-add-notification-config-to-bucket.html#notification-walkthrough-1-test)
* [passing custom metadata to  s3](http://www.bucketexplorer.com/documentation/amazon-s3--amazon-s3-objects-metadata-http-header.html)
* [sns notification  structure](http://docs.aws.amazon.com/AmazonS3/latest/dev/notification-content-structure.html)
* [ngrok   tool](https://blogs.aws.amazon.com/php/post/Tx2CO24DVG9CAK0/Testing-Webhooks-Locally-for-Amazon-SNS)
* [confirm sns   suscription](http://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.html#SendMessageToHttp.confirm)
* https://github.com/aws/aws-sdk-ruby/pull/1122/files
