# Notes on AWS Amazon EC2

## adding EBS volume to EC2 

list all availible mount points (EBS and EC2)

after you sign up for EBS partiotion and you associate it to your EC2
instance 

```
lsblk

#you should see something like:

NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk
└─xvda1 202:1    0   8G  0 part /
xvdb    202:16   0  20G  0 disk            # this is the EBS voluem
```


new SSD drives are not formated, you can do that with:

sudo mkfs -t ext4 /dev/xvdb
```

now you can

```
sudo mount /dev/xvdb /mnt/my-data
```

source 
* https://forums.aws.amazon.com/message.jspa?messageID=519761
* http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-add-volume-to-instance.html



