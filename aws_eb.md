* elastic search
* redis is in elastic cache
* postgre is in RDS


# debugging eb aws docker

```
tail /var/log/eb-activity.log -n 100
tail /var/log/docker.log -n 100

```


# eb cli

installing

```
# on ubuntu 14.04
sudo apt-get install python-pip
sudo pip install awsebcli
# now you have the `eb` command, make sure to update your credentials in
# ~/.aws/config
#
#     [profile eb-cli]
#     aws_access_key_id = A******************Q
#     aws_secret_access_key = A**************************************U
#     
#     [default]
#     aws_access_key_id = A******************Q
#     aws_secret_access_key = Ar************************************XU
#     region = eu-west-1

```

usage

```
eb init --interactive
eb ssh productionMycom-env
eb deploy qaMyEnvironment #deploy currently commited code
```





# eb logs

```
eb logs  # application logs (downoads them to s3 and then display)
eb logs -a  #all logs including cron 

eb status
eb open # opens website
eb local # not yet implemented but in future it vil provision the docken
         # AWS  on your localhost

eb push # alias to "git aws.push"  takes head commit of branch and
        # deploy to aws


## export / retrieve PostgreSQL dump from EBS RDS

the way how RDS backups works is that they create snapshot of the RDS
instance including data, therefore when you retrieving RDS backup you
are just rolling back state of snapshot. This is eficient enough as
backup
There is no way how to pull this snapshot from AWS. 

The only way how to acually do real `pg_dump` is to do fallowing

1. create a new micro EC2 instance and add it to *same security group as your production webservice* (...or create new security group so that this instance will have right to create connection to Postgresql 5432) # I'm not recommending SSH to one of your production EC2 instance
2. instal pg_dump on this instance 
3. `pg_dump dbname=my_db_name --username=my_db_username
   --host=somethingsomething.com --password > /tmp/dump.sql`
4. `scp` to your computer
