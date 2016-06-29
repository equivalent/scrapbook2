* how to install cluster    https://www.elastic.co/blog/running-elasticsearch-on-aws
* benchmarking   https://www.elastic.co/blog/announcing-rally-benchmarking-for-elasticsearch

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
