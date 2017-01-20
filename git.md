# Git scrapbook

```
# show  file lists changed been modified between 2 branches
git diff --name-status DEVELOPMENT...feature/2420_part2
```


```
# show commit difference between 2 branches
git log master..DEVELOPMENT 
```

```
git log --decorate --graph
git reflog
```

### git-crypt (gitcrypt)

usage:

```sh
mkdir  foo
cd foo
git init
gitcrypt init

# Generate a random salt? [Y/n] n
# Shared salt as hex characters: mysecretsalt
# Generate a random password? [Y/n]n
# Enter your passphrase: mysecretpassword
# What encryption cipher do you want to use? [aes-256-ecb] 
# Do you want to use .git/info/attributes? [Y/n] y
# What files do you want encrypted? [*] 
# git-encrypt filter enabled
#
#  ...or just copy configuration to .git/config
```

##### git-crypt instalation

```sh
$ git clone https://github.com/shadowhand/git-encrypt
$ cd git-encrypt
$ chmod 0755 gitcrypt
$ sudo ln -s "$(pwd)/gitcrypt" /usr/local/bin/gitcrypt
$ gitcrypt -h
```

* https://github.com/shadowhand/git-encrypt
* https://www.agwa.name/projects/git-crypt/

### git cancle merge / reset merge

```
git reset --hard 03400a8da200607be2a7a85b33e9ab86de89fc3d
```

### gitigtore

```
*.swp                   # ignore all files with .swp extension in all folders
tmp                     # ignore all "tmp" files/folders 
/config.yml             # ignore config.yml only in root of an application ( ./app/config.yml wont be ignored)
/foo/bar/car            # this will ignore file "car" in folder ./foo/bar
                        # so file "car" in folder ./foo/  wont be ignored
```

if your file is allready cached (you done `git add somefolder/myfile`) you can remove it with:

```sh
git rm --cached somefolder/myfile
# or git rm -r --cached somefolder   # to remove whole folder from cache
```

this will remove it from cache, now git will read your `.gitignore` file and if that file is ignored when you do:

```sh
git add .
git commit -m "without myfile "
```

...you wont commit that file

If you want to ignore file that was already commited you must remove that file first 

```sh
git rm somefolder/my_file
# or git rm -r somefolder   #deletes whole folder
```



### Git squash commits

```bash
git rebase -i HEAD~3    # HEAD-number_of_how_many_last_commits
```

then in text editor pick and squash your commits (don't change order)

```
pick f392171 Added new feature X
squash ba9dd9a Added new elements to page design
squash df71a27 Updated something
```

then another edittor will trigger wher you will be prompted to define one commit message the whole squash

If you want to push on branch that already contains your commits, you have to force it by doinf 

```bash
git push origin +name_of_the_branch
```

* http://ariejan.net/2011/07/05/git-squash-your-latests-commits-into-one/
* http://stackoverflow.com/questions/5667884/how-to-squash-commits-in-git-after-they-have-been-pushed


### How to update forked repository

e.g.: you forked repo on github and now you want to update it with latest changes from original

```bash
git remote add upstream https://github.com/whoever/whatever.git
git fetch upstream
git checkout master
git rebase upstream/maste

git push -f origin master
```


http://stackoverflow.com/questions/7244321/how-to-update-github-forked-repository

### Cherry-picking 

...or how to copy commit from one branch to another

    git log  # pick you SHA
    git co my_other_branch
    git cherry-pick 62ecb3

http://ariejan.net/2010/06/10/cherry-picking-specific-commits-from-another-branch/

### how to undo last local commit 

    git reset --soft HEAD^   #discard last commit

at this point you still have changes in cache

    git reste HEAD           # discard cache
    
now you can either delete/edit stuff or `git co app/my_file`

reference: http://stackoverflow.com/questions/927358/how-to-undo-the-last-git-commit    

_published: 2013-09-12_

***

### how to remove commit from github/remote git repository 

    git push -f origin HEAD^:master     # last commit
    git push -f origin HEAD^^:master    # last two commit
    git push -f origin HEAD^^^:master   # last three commit

That should "undo" the push.

http://stackoverflow.com/questions/448919/how-can-i-remove-a-commit-on-github

_published: 2013-09-12_

***

### git repository on usb external drive

     mkdir /path/to/usb/stick/repository.git
     git clone --local --bare . /path/to/usb/stick/repository.git
     git remote add usb file:///path/to/usb/stick/repository.git
     git push usb master

     git clone file:///path/to/usb/stick/repository.git

if you get  error via cloning:

     Invalid cross-device link

...include an option:

     --no-hardlinks

"You can use the git clone --no-hardlinks option to tell git to take a copy of the files rather than attempt to symlink over to the mounted USB drive."  by [WiredBob](http://blog.costan.us/2009/02/synchronizing-git-repositories-without.html#c2100313269010531565)

sources: http://blog.costan.us/2009/02/synchronizing-git-repositories-without.html

_published: Winter 2012_

