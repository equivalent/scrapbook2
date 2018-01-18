# How to get ElasticSearch total count of items matching

Using the [ElasticSearch Rails](https://github.com/elastic/elasticsearch-rails)
this is how you can get total count of items in ElasticSearch document
that match search query.

In this case we are searching for title "cat" inside "Work" model /
document and we are limiting only 8 results to be returned



```ruby
# this can be anything you need in your business logic
es_query = {:from=>0, :size=>8, :sort=>[{:_score=>{:order=>"desc"}},{"created_at"=>{"order"=>"desc"}}], :query=>{:bool=>{:must=>{:bool=>{:should=>[{:match=>{:title=>{:query=>"cat"}}}]}}}}}

Work.__elasticsearch__.search(es_query).count
# => 8 #...because you are counting just the returned items, not total

Work.__elasticsearch__.search(es_query).results.total
# => 180 # this is the real total in ElasticSearch


```


> Special thx to my collegue [Charlie](https://github.com/charlietarr1) who done the research around this
