# CSV


### Export Active Record Relation to CSV

``` 
model_scope = Model.where.not(id: null).order(:id) # replace this with own condition

CSV.open("/tmp/export.csv", "wb") do |csv|
  csv << Model.attribute_names
  model_scope.find_each do |model|
    csv << model.attributes.values
  end
end
```
