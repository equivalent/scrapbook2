# Heroku

### DB 


create:

```
heroku pg:backups:capture --app  nameoftheapp
Starting backup of postgresql-dimensional-33144... done

Backing up DATABASE to b004... done
```

b004 represents the version of flatest backup for the app

download

```
# url
heroku pg:backups:url b004 --app nameoftheapp


#download to /tmp
cd /tmp
wget $(heroku pg:backups:url b004 --app nameoftheapp)
```

