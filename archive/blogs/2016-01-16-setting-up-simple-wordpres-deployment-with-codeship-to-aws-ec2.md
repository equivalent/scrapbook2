# Setting up simple Wordpress deployment with CodeShip to AWS EC2

The other day I was asked to set up deployment pipe for a blog
website built in Wordpress. Although I was a PHP developer for a few years before I switched to Ruby, I've never worked with WordPress.
Plus the last time I've seen PHP
code was like 6 years ago. That should not be a problem as I will not be
working with Wordpress internals here, however if you find anything I've missed or incorrectly explained please leave a comment (...or even better do a
pull request for this article :) )

I will not be explaining  how to set up Wordpress or how to install
Appache (you have  plenty of articles on that topics [article 1][2]). I will purely explain only
*how to configure CodeShip continues deployment of an existing WordPress
website* (and it will be really basic implementation). I will assume that you have a working Wordpress website in a
directory `/var/www/my-project` and all the database & Apache setup is
working on a VM not on a hosting.

For sake of simplicity the article will be explaining setup on AWS EC2
instance but the steps apply to any VM as long as you can SSH to
it via ssh key-pair.

 I'll  assume that your AWS EC2 instance have a home folder in
`/home/ec2-user/`. Some EC2 instances have `/home/ubuntu` or
`/home/centos` well that's ok just make sure you change any of the lines
in the script bellow to whatever is your EC2 user home folder.

I was told that a good practice in WordPress project is just to
commit and
deploy changes of a template (in our case `my-application/wp-content/themes/mytheme/`).
Therefore this article is not dealing with syncing up plugins or assets.
Just purely deployng changes of a Wordpress template.

## Setup

First step: create a CodeShip project.

Then go to `Project Settings > General` and copy `SSH public key`
for the project to your clipboard. We will need to paste this SSH key to VM (EC2 server).

[ssh to the EC2 instance][1] `ssh ec2-user@ec2-52-66-66-66.eu-west-1.compute.amazonaws.com`
paste the the key to `~/.ssh/authorized_keys`. Make sure you don't delete
any existing keys in the file.

Now clone the project to your home folder `git clone
git@github.com:me/my-project.git`. Therefore now we have a folder `/home/ec2-user/my-project` (not `/var/www`)

Awesome, now go back to CodeShip project and go to `Project Setting >
Deployment`. In section `Configure a branch that triggers the deployment
pipeline` select `Branch starts with` and type `live-`. This way we will
be trigering a deployment to any branch that has this prefix like
`live-20161101`

After you `Save pipline settings` a section  `"Add deployment"` appears. Click the icon that says:
"Custom Script" (big blue dolar sign icon). Paste this to this script
window:

```bash
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

1. sets `$BRANCH_NAME` variable with the name of the branch (e.g.: `live-20161101`) from the
   webhook (yes you can use directly the `$CI_BRANCH` but I like this
   way better as you can override it in future)
2. set some other varibale with location of the git ropo folder
   (`ROOT_FOLDER`), login to the server(`EC2_SERVER`)
3. fetch remote branches on VM
4. checkout to the deployment branch e.g.: `live-20161101` and pull it's
   content (on VM)
5. sync folder `/home/ec2-user/my-project/themes/mytheme/` to
   `https://support.google.com/chromebook/answer/1282338?hl=en-GB`



If you are in doubt what would the `rsync` command override you can just
add `--dry-run` option at the end. This will just output stuf to your
console but wont change any files:

` ssh $EC2_SERVER "rsync -rvI $ROOT_FOLDER/themes/mytheme/ /var/www/my-application/wp-content/themes/mytheme/ --dry-run`

Please remove the `--dry-run` when you're ready.

Ok now on push some change to project Github repo branch `live-20161101`. If configured correctly CodeShip will do the changes of a template.

> **Note:** Be sure that you have your server firewall set up in a way
> that it will enable CodeShip to SSH to you machine othevise the SSH
> connection will Freeze
> https://codeship.com/documentation/faq/enabling-access-to-servers/

[1]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html#ec2-connect-to-instance-linux "Connect to EC2 instance"
[2]: http://coenraets.org/blog/2012/01/setting-up-wordpress-on-amazon-ec2-in-5-minutes/ "Settup WordPress in EC2 instance"
