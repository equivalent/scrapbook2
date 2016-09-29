# Simple Authentication for one user in Rails

Let say you are building really simple website where admin is just one
person. Using authentication gem like
[Devise](https://github.com/plataformatec/devise) may be overkill.

There is an option to use [Basic Auth](http://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic.html) in Rails
but Basic Auth has an issue that you cannot Sign Out
[source](http://stackoverflow.com/questions/233507/how-to-log-out-user-from-web-site-using-basic-authentication). You can close the browser
or send a `401` response to kill the session in browser but if someone
intercept your Token then he can still use it. So you need too be sure
that your entire app is under `https`

> In Rails you can achive https enforcement with `force_ssl` [more here](http://www.eq8.eu/blogs/14-config-force_ssl-is-different-than-controller-force_ssl)

Anyway in this article we will build really simple one user session
solution.

## Model

As we are dealing with only one (or few) users we don't need to store stuff to DB,
we will just store the username
and password to environment variables and we just use Plain Ruby Object
to wrap functionality around comparison and retrieving this values.

```ruby
# app/models/site_user.rb
class SiteUser
  include ActiveModel::Model

  attr_accessor :username, :password

  def login_valid?
    username == ENV['ADMIN_USERNAME'] && password == ENV['ADMIN_PASS']
  end
end
```

In order to load Rails server with the enviroment variable you can
 start it like:

 `ADMIN_PASS=bar ADMIN_USERNAME=foo RAILS_ENV=development rails server`

Or you can use tool like [direnv](http://direnv.net/) or gem [Figaro](https://github.com/laserlemon/figaro) to set local ENV
variables.

> If you want to learn more why storing sensitive data in ENV variable
> is so crucial I'm recommending this article  https://12factor.net/config


## Controller, View and Route to create session

```ruby
# app/controllers/sessions_controller.rb

class SessionsController < ApplicationController
  def new
    @site_user = SiteUser.new
  end

  def create
    # sleep 2 # you can add sleep here  if you want to  slow down brute force attack
              # for normal application this is bad idea but for one
              # user login no-one care

    site_user_params = params.require(:site_user)

    @site_user = SiteUser.new
      .tap { |su| su.username = site_user_params[:username] }
      .tap { |su| su.password = site_user_params[:password] }

    if @site_user.login_valid?
      session[:current_user] = true
      redirect_to '/admin'
    else
      @site_user.password = nil
      flash[:notice] = 'Sorry, wrong credentils'
      render 'new'
    end
  end
end
```

```erb
# app/views/sessions/new.html.erb

<div class="content">
    <section>
      <div style="color: red;"><%= flash[:notice] if flash[:notice]  %></div>

      <%= form_for @site_user, url: sessions_path do |f| %>
        <div>
          <%= f.label :username %>
          <%= f.text_field :username %>
        </div>

        <div>
          <%= f.label :password %>
          <%= f.password_field :password %>
        </div>

        <div>
          <%= f.submit 'Log In' %>
        </div>
      <% end %>
    </section>
</div>
```

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...
  resources :sessions, only: [:create, :new]
  # ...
end
```

## Enforcement of session

```ruby
class ApplicationController < ActionController::Base
  ApplicationNotAuthenticated = Class.new(StandardError)

  rescue_from ApplicationNotAuthenticated do
    respond_to do |format|
      format.json { render json: { errors: [message: "401 Not Authorized"] }, status: 401 }
      format.html do
        flash[:notice] = "Not Authorized to access this page, plese log in"
        redirect_to new_session_path
      end
      format.any { head 401 }
    end
  end

  def authentication_required!
    session[:current_user] || raise(ApplicationNotAuthenticated)
  end
end
```

If you want to use it all you need to do:

```ruby
# entire controller

class MyController < ApplicationController
  before_action :authentication_required!
end

# single action
class MyController < ApplicationController
  def show
    authentication_required!
    @user = User.all
    # ...
    render :show
  end
end
```

##  RESTfull logout with DELETE

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...
  resources :sessions, only: [:create, :new, :destroy]
  # ...
end
```

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # ...

  def destroy
    reset_session
    redirect_to root_path
  end
end
```

```erb
<% if session[:current_user] %>
  <li><%= link_to 'Log OUT', session_path('logout'), method: :delete %></li>
<% end %>
```

##  Logout with GET

The problem with RESTfull logout is that you need Rails UJS included
otherwise the `method: :delete` links will be just GET links. This is
mostly not a problem as you load bunch of Rails lib by default. But if
you are just building a simple website from a downloaded template you
might not necessary load this JS lib.

So here is a solution for GET logout:


```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # ...

  def logout
    reset_session
    redirect_to root_path
  end
end
```

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...
  resources :sessions, only: [:create, :new] do
    collection do
      get :logout
    end
  end
  # ...
end
```

```erb
<% if session[:current_user] %>
  <li><%= link_to 'Log OUT', logout_sessions_path %></li>
<% end %>
```

This way you will end up with logout endpoint `localhost:3000/sessions/logout`

## Rails Admin

If you are using [Rails Admin](https://github.com/sferik/rails_admin)
you can implement the authentication method like this:


```ruby
RailsAdmin.config do |config|
  config.authenticate_with do
    unless session[:current_user]
      flash[:notice] = "Not Authorized to access this page"
      redirect_to main_app.new_session_path
    end
  end

  # ....
```

## Sources and Other reading

* https://www.reinteractive.net/posts/158-form-objects-in-rails
* http://railscasts.com/episodes/250-authentication-from-scratch

