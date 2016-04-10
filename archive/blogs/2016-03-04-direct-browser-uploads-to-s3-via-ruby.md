# Browser upload directly to S3 and triggering SNS notification to your App

In this ar


* create bucket
* assign it CORS
* create user
* save his credentials (aws key id)
* assign him permissions


```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::myapp-browser-uploads-development/*"
            ]
        }
    ]
}
```

> For debugging purpouse you can add  attach `AmazonS3FullAccess` policy
> to user. Just remove it when you done as it's generally bad idea to
> have user that has access to all your S3 buckets and all the opperations







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
