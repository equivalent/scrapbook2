## Amazon CLI AWS

http://docs.aws.amazon.com/cli/latest/reference/
http://docs.aws.amazon.com/cli/latest/reference/s3/index.html

```
aws s3 ls
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
