

```
MyModel.import  #  reindex
MyModel.__elasticsearch__.create_index! # create document
MyModel.__elasticsearch__.delete_index! # delete document

```

check version

`curl localhost:9200`

get everyting

`curl -XGET elasticsearch:9200/`

delete node

` curl -XDELETE elasticsearch:9200/mymodel `
