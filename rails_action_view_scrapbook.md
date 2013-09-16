# Rails Action View scrapbook

http://guides.rubyonrails.org/action_view_overview.html


## Helpers

### Resource path helpers and linking to a resource

```haml
-# resource e.g.: resource = User.last

= link_to edit_resource_path(resource)

= link_to [:edit, resource]
```

```ruby
# app/helpers/application_helper.rb

def delete_button
  link_to resource_path(model), 
    class: %w(destroy button-small),
    data: { confirm: "Are you sure ?" },
    method: :delete do
      content_tag(:i, '', class: "icon-remove") +
      content_tag(:span, 'Delete')
    end
end
```
