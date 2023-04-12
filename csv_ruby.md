# CSV

### write csv

```
csv = []
csv << %w[id created_at]
counter = 0

Order.where(spmething:true).find_each do |order|
  counter += 1
  puts "#{counter} - id:#{order.id} "
  
  row = []
  row << order.id
  row << order.created_at.to_date
  
  csv << row
end

File.write("/tmp/export.csv", csv.map(&:to_csv).join)

```

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
