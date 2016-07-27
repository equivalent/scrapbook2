# Spring Cleaning for WebDevelopers

After some time WebDevelopers local machine (as well as server) gets
full of stuff not needed, here are some commands that I use to erase
unnecessary stuff when needed.

I'm planing to update this article each time I find something new
so if you like this article keep the link somewhere `;-)`

> Warning as this Article is about destructive actions, be really
> careful what you do and don't execute destructive commands mentioned
> here if you don't understand what they are doing.
> I'm not taking any responsibility if you
> remove/destroy some data just because you didn't understood what the
> command is doing.
>
> Don't just copy-paste it !!!


## Standard disk analyzing commands:

Here are some commands to analyze disk space usage, and other stuff.

#### Overal disk space usage in human readable format

```bash
df -h
```

#### Disk usage of Inodes

If you are writing small files on your server (e.g.: file storage cache server) it may happen you will run
out of [Inode](https://en.wikipedia.org/wiki/Inode) space.

```bash
df -ih
```

#### Disk usage of particular folder

```bash
du -sh /tmp/
sudo du -sh  /etc/
```

#### Memory usage

```bash
free -m
```

## Removing Docker images

#### Get rid of all untagged images.

```bash
# non sudo version
docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}")

# sudo version
sudo docker rmi -f $(sudo docker images | grep "<none>" | awk "{print \$3}")
```

> Idea stolen from [Damien Coraboeuf](https://forums.docker.com/t/command-to-remove-all-unused-images/20/4)

#### Get rid of old live releases

I'm tagging my every docker image release with `live-yyyymmdd`, for
example: `quay.io/equivalent/myproject:20151129_0001`


...so in order to remove Images of year 2015 I can do:

```bash
# non sudo version
docker rmi -f $(docker images | grep live-2015 | awk "{print \$3}")

# sudo version
sudo docker rmi -f $(sudo docker images | grep live-2015 | awk "{print \$3}")
```

...in order to remove January images of 2015 I can do:

```bash
# non sudo version
docker rmi -f $(docker images | grep live-201601 | awk "{print \$3}")

# sudo version
sudo docker rmi -f $(sudo docker images | grep live-201601 | awk "{print \$3}")
```

... or if you use format like `live-yyyymmdd_xxxx` where `xxxx` is
release number of a day (`live-20160130_0002`) you can do 

```bash
# non sudo version
docker rmi -f $(docker images | grep live-201602.._ | awk "{print \$3}")

# sudo version
sudo docker rmi -f $(sudo docker images | grep live-201602.._ | awk "{print \$3}")


# two dots in this context represent regular expression "any two char" before underscore
```

...or if you are a Ruby developer and you prefer Ruby syntax or you have no idea what awk does:

```bash
# non sudo version
docker rmi -f $(docker images | ruby -ne 'puts $_.split[2] if $_.match(/live-201602\d\d_/)')

# sudo version
sudo docker rmi -f $(sudo docker images | ruby -ne 'puts $_.split[2] if $_.match(/live-201602\d\d_/)')
```


> **Quick tip:** similar way you can quickly run Rails console on running docker container running
> Rails (assuming your docker image name contains word rails)
> `rails_container_id=$(sudo docker ps | ruby -ne 'puts $_.split.first if $_ =~ /rails/') && sudo docker exec -it   $rails_container_id  rails c`

### Docker containers cleanup

To see list of all  docker containers

```bash
docker ps -a

# sudo version
sudo docker ps -a
```

To see overal size of containers

```bash
docker ps -as

# sudo version
sudo docker ps -as

#   NAMES        #...                 SIZE
# b455d4dc8320   #...  2 B (virtual 1.512 GB)
# 9aaf4133edd6   #...  0 B (virtual 132.3 MB)
# ed37f797b6f4   #...  0 B (virtual 132.3 MB)
# 96db55573ae8   #...  2 B (virtual 1.512 GB)   
```

But this is not actually a full picture !

As described by Maciej Łebkowski in his excelent [article](https://lebkowski.name/docker-volumes/):

> docker run leaves the container by default. This is convenient if you’d
> like to review the process later -- look at the logs or exit status.
> This also stores the aufs filesystem changes, so you can commit the
> container as a new image.
> This can be expensive in terms of disk space usage, especially during
> testing. Remember to use docker run --rm flag if you don’t need to
> inspect the container later. This flag doesn’t work with background
> containers (-d), so you’ll be left with finished containers anyway.

So in order to remove this dead containers run this command:

```bash
docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v

# sudo version

sudo docker ps --filter status=dead --filter status=exited -aq | xargs sudo docker rm -v
```

I had a situation where I runned every command possible but still my
`/var/lib/docker/containers` had several GB. This command dropped 100%
usage to 30%

## Removing old release Git branches

After some time release branches piles up and we may want to clean up
our Github from old `live-*` branches

Given we name our release branches `live-20150821` (`live-yearmmdd`) here is an example how to remove all live branches from previous year (Given it's 2016)

* cd to the repo of your project you want to cleanup
* create the `cleanup.rb` with content bellow
* lunch `ruby cleanup.rb`

```ruby
# cleanup.rb
old_live_branches = `git fetch origin && git branch -r | grep live-2015`  # all branches `live-2015*`
old_live_branches
  .split("\n")
  .map(&:strip)
  .map { |i| i.gsub("/", ' :') }
  .each do |destroy|
    # e.g.: git push origin :live-20151129
    puts `git push #{destroy}`
  end
```

you can do the same with your local git (on your computer)

```ruby
old_live_branches = ` git branch | grep live-2015`  # all local branches
`live-2015*`
old_live_branches
  .split("\n")
  .map(&:strip)
  .each do |destroy|
    # e.g.: git branch -D live-20151129
    puts `git branch -D #{destroy}`
  end
```

source of info:

* http://ruby-on-rails-eq8.blogspot.co.uk/2016/03/removing-old-release-branches.html
* https://github.com/equivalent/scrapbook2/blob/master/archive/mini-blogs/2016-03-02-removing-old-remote-branches-in-bulk.md


## Free up space on your Linux server

#### Delete downloaded packages (.deb) 

E.g.: already installed (and no longer needed)

```bash
sudo apt-get clean
```

#### Remove stored archives in your cache 

E.g.:  packages that can not be downloaded anymore, packages are no
longer in the repository or that have a newer version in the repository

```bash
sudo apt-get autoclean
```

#### Remove packages after uninstalling an application

```bash
sudo apt-get autoremove
```

#### Remove old unused kernels

list all your kernels (installed and deinstalled) :

```bash
dpkg --get-selections | grep linux-image
```

your currently used kernel

```bash
uname -r
```

to remove  particular kernel:

```bash
sudo apt-get remove --purge linux-image-X.X.XX-XX-generic
```

You can also run this script that will remove all unnecessary  kernels,
**Be really really carefull with this !!**
server.

```bash
#!/bin/sh
dpkg -l linux-*  | \
awk '/^ii/{ print $2}' | \
grep -v -e `uname -r | cut -f1,2 -d"-"` | \
grep  -e '[0-9]' | xargs sudo apt-get -y purge
```

* `dpkg -l linux-*` list all kernels
* `uname -r` will tell you current kernel

Source of information:

* http://askubuntu.com/questions/138026/how-do-i-delete-kernels-from-a-server
* http://askubuntu.com/questions/5980/how-do-i-free-up-disk-space
* http://ubuntuforums.org/showthread.php?t=2291788
* https://github.com/equivalent/scrapbook2/blob/master/archive/mini-blogs/2015-01-28-free-up-space-on-your-linux-server.md
* http://ruby-on-rails-eq8.blogspot.co.uk/2015/01/free-up-space-on-your-linux-ubuntu.html


## When stuff goes wrong

#### clean up /boot partition

when you install kernel and you get error similar to this one: 

```bash
update-initramfs: Generating /boot/initrd.img-3.13.0-62-generic

gzip: stdout: No space left on device
E: mkinitramfs failure cpio 141 gzip 1
update-initramfs: failed for /boot/initrd.img-3.13.0-62-generic with 1.
run-parts: /etc/kernel/postinst.d/initramfs-tools exited with return
code 1
dpkg: error processing package linux-image-extra-3.13.0-62-generic
(--configure):
 subprocess installed post-installation script returned error exit
status 1
No apport report written because MaxReports has already been reached
                                                                    Processing
triggers for initramfs-tools (0.103ubuntu4.2) ...
update-initramfs: Generating /boot/initrd.img-3.13.0-62-generic



gzip: stdout: No space left on device
```

it may be you run out of space on boot partition

```bash
df /boot      # 100%
ls /boot
```

```bash
-rw-r--r--  1 root root  1169023 May 26 20:18 abi-3.13.0-54-generic
-rw-r--r--  1 root root  1169023 Jun 18 01:14 abi-3.13.0-55-generic
-rw-r--r--  1 root root  1169201 Jun 19 10:30 abi-3.13.0-57-generic
-rw-r--r--  1 root root  1169346 Jul  8 04:00 abi-3.13.0-58-generic
-rw-r--r--  1 root root  1169346 Jul 24 23:11 abi-3.13.0-59-generic
-rw-r--r--  1 root root  1169346 Jul 29 12:40 abi-3.13.0-61-generic
-rw-r--r--  1 root root  1169478 Aug 11 15:51 abi-3.13.0-62-generic
-rw-r--r--  1 root root  1169421 Aug 14 22:58 abi-3.13.0-63-generic
-rw-r--r--  1 root root   169832 May 26 20:18 config-3.13.0-54-generic
-rw-r--r--  1 root root   169832 Jun 18 01:14 config-3.13.0-55-generic
-rw-r--r--  1 root root   169832 Jun 19 10:30 config-3.13.0-57-generic
-rw-r--r--  1 root root   169832 Jul  8 04:00 config-3.13.0-58-generic
-rw-r--r--  1 root root   169832 Jul 24 23:11 config-3.13.0-59-generic
-rw-r--r--  1 root root   169833 Jul 29 12:40 config-3.13.0-61-generic
-rw-r--r--  1 root root   169833 Aug 11 15:51 config-3.13.0-62-generic
-rw-r--r--  1 root root   169833 Aug 14 22:58 config-3.13.0-63-generic
```

Remove the old kernels like this:

```bash
sudo dpkg --purge linux-image-3.13.0-53-generic
sudo dpkg --purge linux-image-3.13.0-54-generic
# ...
sudo apt-get -f install # tell to continue installing the latest kernel
sudo apt-get autoremove
```


