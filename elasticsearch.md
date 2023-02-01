* how to install cluster    https://www.elastic.co/blog/running-elasticsearch-on-aws
* benchmarking   https://www.elastic.co/blog/announcing-rally-benchmarking-for-elasticsearch


## total number of docs in index

[count endpoint](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-count.html)

```
GET /my-index-000001/_count?q=user:kimchy

GET /my-index-000001/_count
{
  "query" : {
    "term" : { "user.id" : "kimchy" }
  }
}
```

or search q

```
GET /my-index/_search


```
        {"query":{"bool":{ "match_all": {} }},"size":0,"track_total_hits":true}

        {"query":{"bool":{
              "filter":[
                { "term": { "name": "niki" } }
              ]
            }},"size":0,"track_total_hits":true}
            
```

note: set the size to 1 if you want sample doc in result 

## metrics

https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html

get CPU memory

`GET /_nodes/stats/process` 


## difference between filter must must_not shoud

![Q6bOY](https://user-images.githubusercontent.com/721990/215467477-cb0407f3-a2a1-4db6-b1cb-dd4a62e45da1.png)

Filters are cached

term must be mapped to `not_analyzed` [why term query dont return any results and how filters are chached](https://www.elastic.co/guide/en/elasticsearch/guide/current/_finding_exact_values.html#_term_filter_with_text)

## Elasticsearch custom routing ( `_routing` field )

* https://www.elastic.co/blog/customizing-your-document-routing
* https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-routing-field.html#mapping-routing-field


## Change mapping of an index

https://www.youtube.com/watch?v=YSd1aV3iVhM&
https://www.youtube.com/watch?v=PgMtklprDfc
https://www.elastic.co/guide/en/elasticsearch/reference/current/keyword.html

Given `articles` is name of the index

to check mapping 

`GET /articles/_mappings`

post new index with desired mapping

```
PUT articles_v2
{
  "mappings": {
    "properties": {
      "tags": {
        "type":  "keyword"
      }
    }
  }
}
```

copy index over

```
POST _reindex
{
  "source": {
    "index": "articles"
  },
  "dest": {
    "index": "articles_v2"
  }
}
```

the Post request may time out but reindex is in progres. Took like 30 min to copy 13 mil simple indexes.

to check progres chec total num of documents in index 

```
GET /articles_v2/_search

         {"query":{
              "match_all": {}
            },"size":0,"track_total_hits":true}
```

## Bulk insert

a.k.a batch insert

     def bulk_insert(articles)
      Article.__elasticsearch__.client.bulk index: Article.index_name,
        body:  articles.map { |a| { index: { data: a.as_indexed_json } } },
        refresh: true
     end
     bulk_insert(Article.last(1000))
     
        
* https://github.com/elastic/elasticsearch-rails/blob/d12d812c3f52ac484cf73805ef41986dd95ba5a0/elasticsearch-model/examples/ohm_article.rb#L77  
* https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html 
* https://github.com/elastic/elasticsearch-ruby/blob/b20952b38a810a651ea456fad00c45d6f65ecced/elasticsearch-api/spec/elasticsearch/api/actions/bulk_spec.rb

* https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html


## Index documents at scale 

* [How to Reindex One Billion Documents in One Hour at SoundCloud
](https://developers.soundcloud.com/blog/how-to-reindex-1-billion-documents-in-1-hour-at-soundcloud)
* [Tune for indexing speededit elastic.co](https://www.elastic.co/guide/en/elasticsearch/reference/current/tune-for-indexing-speed.html#_disable_refresh_and_replicas_for_initial_loads)

you need to [bulk insert](https://github.com/equivalent/scrapbook2/blob/master/elasticsearch.md#bulk-insert) data to ES

In order to better handle requests you want optimal primary shard number (but that's a static setting = once index is created cannot be changed)

Stuff you can do without creating new index (a.k.a Dynamic settings)
In order to lower CPU & Memmory during bulk isert and therefore speed up data throughput to ES: 

#### unset refresh intervak

[source](https://www.elastic.co/guide/en/elasticsearch/reference/current/tune-for-indexing-speed.html#_unset_or_increase_the_refresh_interval)

```
PUT /my-index-000001/_setting
{
  "index" : {
    "refresh_interval" : -1
  }
}
```

when -1 is set, the index is not refreshed automatically
default value is 1 =  1 second refresh interval
you can provide a value in seconds, e.g. 30s

#### disable replica for inital indexing

[source](https://www.elastic.co/guide/en/elasticsearch/reference/current/tune-for-indexing-speed.html#_disable_replicas_for_initial_loads)

```
PUT /my-index-000001/_settings
{
  "index" : {
    "number_of_replicas" : 0
  }
}
```

when 0 is set, no data is replicated to replica shards, set to a value > 0 to enable replication

#### set Async index.translog.durability

[source](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-translog.html#_translog_settings)

```
PUT /my-index-000001/_settings
{
  "index" : {
    "translog": {
      "durability": "async"
    }
  }
}
```

once bulk sync done set index.translog.durability to "request" to ensure that the translog is synced to disk after each request


=========================================================================================================================================================

## random notes

Total number of items  in ES :

```
Elasticsearch::Model.client.count(index: Work.__elasticsearch__.index_name)['count']



Article.search("cats", search_type: 'count').results.total

Elasticsearch::Model.client.count(index: 'your_index_name_here')['count']
```

<https://stackoverflow.com/questions/7969739/is-there-a-way-to-count-all-elements-of-an-index-in-elasticsearch-or-tire>

-------------------------


```ruby
# match all  - return all

{
  query: {
           "match_all": {}
         }
}
```














seach priority:

```
# look at the ^num   biger number bigger priority

query[:query][:filtered][:query] = {
  multi_match: {
    query: terms.join(" "),
    fields: ['tags^4', 'school_title^5', 'title^3', 'description^1'],
    type: "most_fields"
  }
}
```




```
    def self.search(query, options={})
      __set_filters = lambda do |key, f|

        @search_definition[:filter][:and] ||= []
        @search_definition[:filter][:and]  |= [f]
      end

      @search_definition = {
        query: {},
        filter: {},
      }

      unless query.blank?
        @search_definition[:query] = {
          bool: {
            should: [
              { multi_match: {
                query: query,
                fields: ['title^10', 'body'],
                operator: 'and',
                analyzer: 'russian_morphology_custom'
              }
              }
            ]
          }
        }
        @search_definition[:sort]  = { updated_at: 'desc' }
        # Without that parameter default is 10
        @search_definition[:size]  = 100
      else
        @search_definition[:query] = { match_all: {} }
        @search_definition[:sort]  = { updated_at: 'desc' }
      end
      __elasticsearch__.search(@search_definition)
    end
```




```
#index one record

MyModel.last.__elasticsearch__.index_document
```

```
MyModel.import  #  reindex all

# only reindex some records
MyModel.import query: -> { where(id: MyModel.some_scope.pluck(:id)) }



MyModel.__elasticsearch__.create_index! # create document
MyModel.__elasticsearch__.delete_index! # delete document

# ...or
MyModel.__elasticsearch__.client.indices.delete index: MyModel.index_name


```

check version

`curl localhost:9200`

get everyting

`curl -XGET elasticsearch:9200/`

delete node

` curl -XDELETE elasticsearch:9200/mymodel `
