# Fetch Amazon s3 (aws) backup from console

If you are using [backup gem](https://github.com/meskyanichi/backup) for crating your backups to s3 bucket (or any other gem, doesn't mather)
logging to your AWS console web interface each time you want to download backu is not only slow. 

Much faster solution is to fetch the dump via console with [s3cmd](http://s3tools.org/s3cmd)

```
sudo apt-get install s3cmd
```

Tirst you need to create user http://docs.aws.amazon.com/IAM/latest/UserGuide/Using_SettingUpUser.html and 
add him role that will allow s3 acces (e.g. S3FullAccess )

Now that you have `Access Key ID` and `Secret Access Key` you can  configure s3cmd

```
s3cmd --configure
```

one thing you shoul avoid are special chars in passphraze http://stackoverflow.com/questions/16512312/s3cmd-incomplete-format-error/16714176#16714176

to try if it works do:

```
s3cmd ls
```

If you see list of your bucket names then it does
If you getting `403` you didn't configure your user role ore you misspeld the key/secret

Depending on where/how you store backups you will list what's the latest backup with:

```
s3cmd ls s3://my-project-production-dbbackup/production_db_backups/my-projcet_backup/
```

and download it with

```
s3cmd get s3://my-project-production-dbbackup/production_db_backups/my-projcet_backup/2014.11.11.10.07.14/my-project_backup.tar /tmp/
```
 
