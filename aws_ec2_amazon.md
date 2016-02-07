# Notes on AWS Amazon EC2


## policy for adding IP to security group

```

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:RevokeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupIngress"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}

# or 

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:RevokeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupIngress"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:ec2:eu-west-1:123myaccountnumber890:security-group/sg-4bbbbb2e"
            ]
        }
    ]
}
```

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

```
sudo mkfs -t ext4 /dev/xvdb
```

now you can

```
sudo mount /dev/xvdb /mnt/my-data
```

source 
* https://forums.aws.amazon.com/message.jspa?messageID=519761
* http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-add-volume-to-instance.html


## encrypt EBS volume

we expect that you created fresh unformated ECB volume and assigned it to EC2 instance
(let say it will be `xvdf`)


#### step 1. setup the ECB volume for encryption

```bash
cryptsetup -y luksFormat /dev/xvdf
```

Verify it with:

```bash
cryptsetup luksDump /dev/xvdf
```

... output will look like:

```
LUKS header information for /dev/xvdf

Version:           1  
Cipher name:       aes  
Cipher mode:       cbc-essiv:sha256  
Hash spec:         sha1  
Payload offset:    4096  
MK bits:           256  
MK digest:         xx 22 e1 53 6a 17 hj xx d8 d7 05 55 b7 ee 57 c0  
MK salt:           ec d3 2e 0s f6 e0 05 7e 30 rf xx 76 8d 26 fg 00  
                   c3 kl a0 db xx 68 39 d9 a5 30 31 jk 51 dx 00 c0
MK iterations:     32375  
UUID:              93x0e44x-9x3x-47x5-b6bx-7428x3edcc10

Key Slot 0: ENABLED  
    Iterations:             129600
    Salt:                   xx 30 9d 9b 5e 6b e9 a4 dd g3 fa b6 80 dc 55
ze
                            9c b0 fg x8 11 9c ec 41 94 hf be cj 40 89 k3
fd
    Key material offset:    8
    AF stripes:             4000
Key Slot 1: DISABLED  
Key Slot 2: DISABLED  
Key Slot 3: DISABLED  
Key Slot 4: DISABLED  
Key Slot 5: DISABLED  
Key Slot 6: DISABLED  
Key Slot 7: DISABLED
```

#### step 2:  create map device

```
cryptsetup luksOpen /dev/xvdf my_encrypted_vol
```

this will basically unencrypt the volume and map the volume to `/dev/mapper/my_encrypted_vol` 


#### step 3:  format it

```bash
mkfs.ext4 -m 0 /dev/mapper/my_encrypted_vol
```

#### step 4:  mount it

```bash
mkdir /mnt/my_encrypted_vol
mount /dev/mapper/my_encrypted_vol /mnt/my_encrypted_vol
```

you can now copy files to `/mnt/my_encrypted_vol`

Final check `cryptsetup status my_encrypted_vol` should say some
encryption stuff

#### NOTE: disable automount

author of the source article was mentioning we should
disable automount in `/etc/grub.conf` however I'm runing ubuntu EC2
instance and couldn't find any evidence of it automouinting


#### unmount

```bash
umount /mnt/my_encrypted_vol
cryptsetup luksClose my_encrypted_vol
```

#### remount

```bash
cryptsetup luksOpen /dev/xvdf my_encrypted_vol
mount /dev/mapper/my_encrypted_vol /mnt/my_encrypted_vol
```

source:

* http://silvexis.com/2011/11/26/encrypting-your-data-on-amazon-ec2/



