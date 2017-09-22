# How to copy entire bucket to another bucket

Let say you want to create a backup 


## How to existing content to replica bucket

(or how to copy content of one bocket to another bucket in different
region )

like discussed in [this SO topic](http://stackoverflow.com/questions/9664904/best-way-to-move-files-between-s3-buckets) developer could just do:

```
aws s3 sync s3://oldbucket s3://newbucket
```

...and that would simply sync up the `oldbucket` content to `newbucket`. 

Problem is that this only works in same AWS region. In order to sync
up our cross origin replica we need to specify source and destination
regions.

```
aws s3 sync s3://my-original-bucket-in-ireland s3://backup-bucket-in-frankfurt --source-region=eu-west-1  --region=eu-central-1
```

Another problem is that if we are transfering Terabytes of data we meigt be staying too late in our office tonight till the script finishes. Also if a power goes down it could cause office switch to interupt the connection + we want to play Dota tonight and we don't want to leave our laptop at work.

Therefore I'm recommending to lunch a EC2 micro instance, ssh to it and install AWS CLI  there. Then run command from  with `nohup` and `&` so it runs in background (read more here  http://www.thegeekstuff.com/2010/12/5-ways-to-execute-linux-command/)

```
cd /tmp/
```

```
nohup aws s3 sync s3://my-original-bucket-in-ireland s3://backup-bucket-in-frankfurt --source-region=eu-west-1  --region=eu-central-1 &
```

Output afret executing will be someting like

```
# [1] 15615
# nohup: ignoring input and appending output to ‘nohup.out’

```




````


 sudo ps aux | grep aws
ec2-user 15615 36.9  6.2 890996 63216 pts/1    Sl   10:31   1:35
/usr/bin/python2.7 /usr/bin/aws s3 sync s3://work.pobble.com
s3://backup-work.pobble.it --source-region=eu-west-1
--region=eu-central-1
ec2-user 15637  0.0  0.2 110460  2204 pts/0    S+   10:36   0:00 grep
--color=auto aws
ec2-user@tomasVMpoble /tmp $ sudo ps aux | grep aws

```
