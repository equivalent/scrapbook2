## CORS permissions on s3 bucket

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>http://www.myapp.com</AllowedOrigin>
        <AllowedOrigin>https://www.myapp.com</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>HEAD</AllowedMethod>
    </CORSRule>
</CORSConfiguration>

```


## browser upload

http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTConstructPolicy.html
https://github.com/waynehoover/s3_direct_upload/blob/master/spec/helpers/form_helper_spec.rb

```
"expiration": "'.date('Y-m-d\TG:i:s\Z', time()+10).'",
"conditions": [
    {"bucket": "xxx"},
    {"acl": "public-read"},
    ["starts-with","xxx",""],
    {"success_action_redirect": "xxx"},
    ["starts-with", "$Content-Type", "image/jpeg"],
    ["content-length-range", 0, 10485760]
]
http://stackoverflow.com/questions/13390343/s3-direct-upload-restricting-file-size-and-type
```


## Amazon CLI AWS

http://docs.aws.amazon.com/cli/latest/reference/
http://docs.aws.amazon.com/cli/latest/reference/s3/index.html

```
aws s3 ls
```


## s3 policy example (2017-01-20)

for the new carrierawave gem 

```
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
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::o365-v2"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::o365-v2/*"
            ]
        }
    ]
}
```


## s3 policy example

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListAllMyBuckets"],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::foo-development",
        "arn:aws:s3:::foo-development-dbbackup"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::foo-development/*",
        "arn:aws:s3:::foo-development-dbbackup/*"
      ]
    }
  ]
}
```


```
## s3 policy example 2 

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
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::bar-app-dbbackup",
                "arn:aws:s3:::foo-app-dbbackup"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::bar-app-dbbackup/*",
                "arn:aws:s3:::foo-app-dbbackup/*"
            ]
        }
    ]
}
```
