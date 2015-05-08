


```haml
= simple_form_for :custom_form,
  url: root_path,
  method: 'get',
  html: { id: 'fetch_custom_form',
  :'data-remote' => true } do |f|
  = f.input :validation_type_id, collection: @application.tld.validation_types
  
```


# bootstrap 3 

https://github.com/rafaelfranca/simple_form-bootstrap
