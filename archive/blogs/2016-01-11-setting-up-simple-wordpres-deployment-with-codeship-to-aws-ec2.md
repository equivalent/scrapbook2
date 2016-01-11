# Setting up simple Wordpress deployment with CodeShip to AWS EC2

The other day I was asked to set up deployment pipe for a Wordpress blog
website. Although I was a PHP developer for few years before I swithed
to Ruby, I've never worked with WordPress. Plus the last time I've seen PHP
code was like 6 years ago. That should not be a problem as I will not be
touching much the internals here but if you find anything I've missed or
incorectly explained please leave a comment (...or even better do a
pull request for this article :) )

I will not explain here how to set up Wordpress or how to install
Appache (you have  plenty of articles on that topics). I'll purely touch
ground of "How to configure CodeShip continues deployment of an existing WordPress
website". I will assume that you have a working Wordpress website in a
directory `/var/www/my-project` and all the database & Apache setup
working on some VM not on a hosting.

For sake of simplicity the article will be explaining setup on AWS EC2
instance but the entire setup apply to any VM as long as you can SSH to
it via ssh key-pair.

 I'll  assume that your AWS EC2 instance have home folder in
`/home/ec2-user/`. Some EC2 instances have `/home/ubuntu` or
`/home/centos` well that's ok just make sure you change any of the lines
in the script bellow to whatever is your EC2 user home folder.

First step create a CodeShip project. Then go to `Project Settings >
General` and copy the `SSH public key` for the project. We will need to
paste this SSH key to EC2 server. 

[ssh to the EC2 instance](1) `ssh ec2-user@ec2-52-66-66-66.eu-west-1.compute.amazonaws.com`
and add the key to `~/.ssh/authorized_keys`. Make sure you don't delete
any existing keys in the file.

Now clone the project to your home folder `git clone
git@github.com:me/my-project.git`. Therefore now we have a folder `/home/ec2-user/my-project`

Awesome now go back to CodeShip project and go to `Project Setting >
Deployment` . In section `Configure a branch that triggers the deployment
pipeline` select `Branch starts with` and type `live-`. This way we will
be trigering a deployment to any branch that has this prefix like
`live-20161101` 

After you `Save pipline settings a section  "Add deployment" appears. Click the icon that says:
"Custom Script" (big blue dolar sign icon). Paste this to this script
window:

```
BRANCH_NAME="${CI_BRANCH}"
ROOT_FOLDER="/home/ec2-user/my-project"
EC2_SERVER="ec2-user@ec2-52-66-66-66.eu-west-1.compute.amazonaws.com"
fetch_branch="cd $ROOT_FOLDER && git fetch origin" && echo $fetch_branch
ssh $EC2_SERVER $fetch_branch
pull_branch="cd $ROOT_FOLDER && git checkout $BRANCH_NAME && git pull
origin $BRANCH_NAME" && echo $pull_branch
ssh $EC2_SERVER $pull_branch
ssh $EC2_SERVER "rsync -rvI $ROOT_FOLDER/themes/mytheme/ /var/www/my-application/wp-content/themes/mytheme/"
```

The script does following:

1. sets `$BRANCH_NAME` variable with the name of the branch from the
   webhook (yes you can use directly the `$CI_BRANCH` but I like this
   way better as you can overide it in future)
2. set some other varibales with location of the git



If you are in doubt what would the `rsync` command overide you can just
add `--dry-run` option at the end. This will just output stuf to your
console but wont change any files:

` ssh $EC2_SERVER "rsync -rvI $ROOT_FOLDER/themes/mytheme/ /var/www/my-application/wp-content/themes/mytheme/ --dry-run`

Please remove the `--dry-run` when you're ready.

[1][http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html#ec2-connect-to-instance-linux]
