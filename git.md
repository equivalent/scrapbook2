# Git scrapbook

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

