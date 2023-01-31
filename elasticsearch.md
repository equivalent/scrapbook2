* how to install cluster    https://www.elastic.co/blog/running-elasticsearch-on-aws
* benchmarking   https://www.elastic.co/blog/announcing-rally-benchmarking-for-elasticsearch




## difference between filter must must_not shoud

![Q6bOY](https://user-images.githubusercontent.com/721990/215467477-cb0407f3-a2a1-4db6-b1cb-dd4a62e45da1.png)

## Elasticsearch custom routing 

https://www.elastic.co/blog/customizing-your-document-routing




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
