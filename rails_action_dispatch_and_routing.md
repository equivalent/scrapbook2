### polymorphic routes

http://api.rubyonrails.org/classes/ActionDispatch/Routing/PolymorphicRoutes.html


    = link_to 'Edit', edit_polymorphic_path([@contentable, @content])
    = link_to 'New',  new_polymorphic_path([@contentable, Content.new])
    = link_to 'index', polymorphic_path([@contentable, @content])
    = link_to 'index', polymorphic_path([@contentable, Content.new])

also can be achived with 

    = link_to 'edit', [:edit, @contentable, @content]


### url_for

    url_for(controller: :documents, action: :index)


# Console

### how to access url helpers from cosole / specs / tests

```ruby
include Rails.application.routes.url_helpers
     
# set host in default_url_options:
default_url_options[:host] = "localhost"
     
# can then use:
url_for()
     
# can check existing routes:
edit_user_url(User.first)
=> "http://localhost/user/1/edit"
```

source: http://snipplr.com/view/37063/

# Routes config

### sharing nested resource

```ruby
MyCoolApp::Application.routes.draw do

  def contentable
    resources :contents do
      get :publish, on: :member
    end
  end
  
  resource :candies
    contentable
  end
  
  resource :factories
    contentable 
  end

end
```
