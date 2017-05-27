# Send files from Server

Sometimes you are on a server where you generate export file. It's easy
to just `scp` the file from the server to your local machine.

```bash
scp user@server.com:/tmp/myfile.csv  /tmp/local_folder/
```

But some times you are dealing
with a situation where you can `ssh` but you cannot `scp`
(AWS Elastic Beanstalk is a good example)

If the file don't contain private data (passwords, emails) what you can do is email
the file on your work email.

Steps:

* install `mutt` mail command (simple mailng inteface supporting
attachment files)
* compress your file / folder
* send file attachment with  with `mutt`

`mutt` syntax:

```bash
echo "mail body" | mutt -a file -s "Subject" -- my@email.com
```

example:


```bash
## install mutt command:
#
# sudo apt-get install mutt
# sudo yum install mutt

# Given we have generated `views.csv` file
gzip views.csv
echo "mail body" | mutt -a views.csv.gz -s "MyApp view stat files" -- tomas@eeeeeeeeeeeeq.ee


# Given we mupltiple files in directory `views/`
tar -zcvf views.tar.gz views/
du -sh views.tar.gz

echo "mail body" | mutt -a views.tar.gz -s "MyApp view stat files" -- tomas@eeeeeeeeeeeeq.ee
```


**Warning** I do recommend to encrypt the file before sending 

e.g.:

```bash

zip -P password file.zip file

# ...or:

zip -e file.zip file

# ...or:

gpg -o fileToTar.tgz.gpg --symmetric fileToTar.tgz

# to decrypt
gpg fileToTar.tgz.gpg
```


#### Sources

* https://github.com/equivalent/scrapbook2/blob/master/linux.md
* https://superuser.com/questions/370389/how-do-i-password-protect-a-tgz-file-with-tar-in-unix
