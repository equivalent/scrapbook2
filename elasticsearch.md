* how to install cluster    https://www.elastic.co/blog/running-elasticsearch-on-aws
* benchmarking   https://www.elastic.co/blog/announcing-rally-benchmarking-for-elasticsearch




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


## Index documents at scale 

https://developers.soundcloud.com/blog/how-to-reindex-1-billion-documents-in-1-hour-at-soundcloud


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
