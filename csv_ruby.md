# CSV

### Write CSV line by line

```
require "csv"

def x(row)
  File.write('/tmp/exp.csv', row.to_csv, mode: 'a+')
end

Order.all.find_each do |order|
  x([order.id, order.created_at])
end
```


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
