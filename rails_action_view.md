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

### Block partial render 

in short this is not possible, partials are not designed to pass blocks what you want to use is render layout 
([from](http://stackoverflow.com/questions/2951105/rails-render-partial-with-block))

```erb
<% render :layout => '/shared/panel', :locals => {:title => 'some title'} do %>
  <p>Here is some content</p>
<% end %>
```

or create a helper that will accept block and pass it as a variable to partial 

```ruby
module ContentHelper
  def content_column_fields(options, &block)
    options.merge!(:block_body => capture(&block))
    render(:partial => 'column_fields', :locals => options)
  end
end
```

```haml
-# app/view/contents/_column_fields
%h3 Example #{name}
= block_body

-# app/view/contents/_form.html.haml

[:foo, :bar].each do |column|
  = content_column_fields name: "some kind of name" do
    - radio_button_tag 'foo'
```

source 

* http://www.igvita.com/2007/03/15/block-helpers-and-dry-views-in-rails/
