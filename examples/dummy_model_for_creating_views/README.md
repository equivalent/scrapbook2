# Dummy model for creating views

`field.rb` is an example of ghost model used when you crating interface before creating your data structure.


with this model views/paths/forms similar to these will work : 

```ruby
# config/routes

MyApp::Application.routes.draw do

  resources :tlds do
    resources :fields
  end

end
```


```ruby
# app/views/fields/_form.html.haml
= simple_form_for [@tld, @field] do |f|
  = f.input :name
  = f.button :wrapped, 'Save', cancel: tld_fields_path(@tld)
```

```ruby
# app/views/fields/index.html.haml
      # ...
      - fields.each do |field|
        %tr
          %td= field.name
          %td= field.type
          %td.actions
            %ul.list-inline
              %li= edit_button [@tld, field]
```
