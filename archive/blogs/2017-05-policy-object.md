# Policy Objects in Ruby on Rails

Doing authentication (verifying if user is sign-in or not) in Ruby on Rails is quite easy.
You can [write your own simple authentication in Rails](http://www.eq8.eu/blogs/31-simple-authentication-for-one-user-in-rails) or you can use
[devise gem](https://github.com/plataformatec/devise) on any equivalent
and you are good to go.

When it comes to authorization (verifying if current_user has permission
to do stuff he/she is requesting to) it's a different topic. Yes there
are several solutions out there that works well on small project ([CanCanCan](https://github.com/CanCanCommunity/cancancan), [Rolify](https://github.com/RolifyCommunity/rolify),
...) but once your project grows to medium to large scale then these
generic solutions may become a burden.

In this article I will show you how you can do your Authorization with
policy classes.

> Note: there is a gem [pundit](https://github.com/elabs/pundit) that is really nice plain Ruby
> policy object solution. But in this article we will work with a
> solution from a scratch. But if you look for gem with established convention and community I recommend checking Pundit.

## Example

Let say in our application user can be:

* *regular user* that can only do read operations of public data of
  clients
* *moderator* for a particular Client that can edit client data and see
  private data for that client
* *admin* which means he will be able to do anything


The code in model could look like this:

```ruby
class Client < ActiveRecord::Base
  # ...
end
```

```ruby
class User < ActiveRecord::Base

  def admin?
    # ...
  end

  def moderator_for?(client)
    # ..
  end
end
```

We don't care how we retriving the information for these methods. It may
be relational DB flag, it may be  [Rolify](https://github.com/RolifyCommunity/rolify) `has_role?(:admin?)`.
It doesn't matter.

Usually when developers start implementing this to the application
logic they will do something like this.

```ruby
# app/controllers/clients_controllers.rb

class ClientsController < ApplicationController
  before_filter :authenticate_user! # Devise check if current user is sign_in or not (is he/she authenticated)
  before_filter :set_client


  def show
  end

  def edit
    if current_user.admin? || moderator_for(@client)
      render :edit
    else
      render text: 'Not Authorized', status: 403
    end
  end

  # ...

  private

  def set_client
    @client = Client.find(params[:id])
  end
end
```

And in view


```ruby
# app/views/clients/show.html.erb

Clients Name: <%= @client.name %>

<% if current_user.admin? || current_user.moderator_for(@client) %>
  Clients contact: <%= @client.email %>
<% end %>
```

Now lets stop here and review. We have a code duplication in our
controller and our view for checking `current_user` role in this
scenario.

If business requirements change developers will have to change this in
multiple places.


## Refactoring to policy helpers

It's crucial to keep your policy definitions in common place so that
other developers will have to change just one file in case the
requirement changes.

We may refactor this to Rails `helper_method`:

```ruby
# app/controllers/clients_controllers.rb

class ClientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_client

  def show
  end

  def edit
    if can_moderate_client?
      render :edit
    else
      render text: 'Not Authorized', status: 403
    end
  end

  # ...

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def can_moderate_client?
    current_user.admin? || current_user.moderator_for(@client)
  end
  helper_method :can_moderate_client?
end
```

```ruby
# app/views/clients/show.html.erb

Clients Name: <%= @client.name %>

<% if can_moderate_client? %>
  Clients contact: <%= @client.email %>
<% end %>
```

This will work just fine for small projects. But once you're dealing
with large project policy helpers will get messy with other helpers.
Let's introduce something more sophisticated.

## Policy Object

Let's enable new autoload path `app/policy/` in Rails:

```ruby
module Pobble
  class Application < Rails::Application
    # ...
    config.autoload_paths << Rails.root.join('app', 'policy')
    # ...
  end
end
```

And write our policy class:

```ruby
# app/policy/client_policy.rb
class ClientPolicy
  attr_reader :current_user, :resource

  def initialize(current_user:, resource:)
    @current_user = current_user
    @resource = resource
  end

  def able_to_moderate?
    current_user.admin? || current_user.moderator_for(resource)
  end
end
```

Our controller will look like this:

```ruby
# app/controllers/clients_controllers.rb
class ClientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_client

  def show
  end

  def edit
    if client_policy.able_to_moderate?
      render :edit
    else
      render text: 'Not Authorized', status: 403
    end
  end

  # ...

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_policy
    @client_policy ||= ClientPolicy.new(current_user: current_user, resource: @client)
  end
  helper_method :client_policy
end
```

And our view like:

```ruby
# app/views/clients/show.html.erb

Clients Name: <%= @client.name %>

<% if client_policy.able_to_moderate? %>
  Clients contact: <%= @client.email %>
<% end %>
```

Now beauty of this is that you have single place where you keep your
policy definitions (so if a new requirement comes it's easy to change)
and you've removed responsibility from controller to know policy
implementation, therefore it's easier to test.

Here is a test example:


```ruby
# spec/policy/client_policy_spec.rb
require 'rails_helper'

RSpec.describe ClientPolicy do
  subject { described_class.new(current_user: user, resource: client }
  let(:client) { Client.new } # feel free to use factory_girl gem on this

  context 'when current user regular user' do
    let(:user) { User.new }

    it { expect(subject).not_to be_able_to_moderate }
  end

  context 'when current user is an admin' do
    let(:user) { User.new admin: true }

    it { expect(subject).to be_able_to_moderate }
  end

  context 'when current user is a client moderator' do
    let(:user) { User.new.tap { |u| u.moderable_clients << client } }

    it { expect(subject).to be_able_to_moderate }
  end

  context 'when current user is unrelated client moderator' do
    let(:user) { User.new.tap { |u| u.moderable_clients << Client.new } }

    it { expect(subject).not_to be_able_to_moderate }
  end
end
```

As we are testing various Authorization scenarios in our policy object
test, all we need to test in our controller is that policy object
calls the policy method that our controller action desires.

```ruby
# spec/controllers/clients_controller.rb
require 'rails_helper'

RSpec.describe ClientsController do
  let(:client) { create :client }
  # ...

  describe 'GET edit' do
    def trigger; get :edit, id: client.id end


    context 'not logged in' do
      it 'should not access this page' do
        trigger
        expect(response.status).to eq 401 # not authenticated, e.g.: Devise restriction
      end
    end

    context 'logged in' do
      let(user) { User.new }
      let(:policy_double) { instance_double(ClientPolicy) }

      before do
        sign_in(user)

        expect(ClientPolicy)
          .to receive(:new).with(current_user: user, resource: client)
          .and_return(policy_double)
        expect(policy_double).to_receive(:able_to_moderate).and_return(policy_result)
      end

      context 'as authorized user' do
        let(:policy_result) { true }

        it 'should allow page render' do
          trigger
          expect(response.status).to eq 200
        end
      end

      context 'as non-authorized user' do
        let(:policy_result) { false }

        it do
          trigger
          expect(response.status).to eq 403
        end
      end
    end
  end

  # ...
end
```

## Scopes

Ok let say we have a requirement that on our `#index` page we can only list clients that
have `public` flag or that current_user can moderate.

If we put all the logic in controller the code may look like this:

```ruby
# app/controllers/clients_controllers.rb
class ClientsController < ApplicationController
  # ...

  def index
    if current_user.admin?
      @clients = Client.all
    elsif current_user.clients.any?
      @clients = current_user.clients
    else
      @clients = Client.where(public: true)
    end
  end

  # ...
end
```

Let's introduce Policy Scope:


```ruby
# app/policy/client_policy.rb
class ClientPolicy
  class Scope
    attr_reader :current_user, :scope

    def initialize(current_user:, scope:)
      @current_user = current_user
      @scope = scope
    end

    def displayable
      return scope if current_user.admin?

      if current_user.clients.any?
        scope.where(id: current_user.clients.pluck(:id))
      else
        scope.where(public: true)
      end
    end
  end

  # ...
end
```

```ruby
# app/controllers/clients_controllers.rb
class ClientsController < ApplicationController
  # ...

  def index
    @clients = Client.all
    @clients = ClientPolicy::Scope
                 .new(current_user: current_user, scope: @clients)
                 .displayable

    # you can implement more scopes e.g. @clients.order(:created_at)
    # or @clients pagination

    # ...
  end

  # ...
end
```

> This kind of objects are called Query Policy Objects. To learn more what they are and how to test them  I recommend my article  [Rails scopes composition and query objects](http://www.eq8.eu/blogs/38-rails-activerecord-relation-arel-composition-and-query-objects)


## Getting complex

Here is an example of real world complex policy object:

```ruby
# app/policy/client_policy.rb
class ClientPolicy
  attr_reader :current_user, :resource

  def initialize(current_user:, resource:)
    @current_user = current_user
    @resource = resource
  end

  def able_to_view?
    resource.id.in?(public_client_ids) || internal_user
  end

  def able_to_update?
    moderator?
  end

  def able_to_delete?
    moderator?
  end

  def as_json
    {
      view: able_to_view?,
      edit: able_to_edit?,
      delete: able_to_delete?
    }
  end

  private

  def admin?
    current_user.has_role(:admin)  # in this case we use Rolify style to determin admin
                                   # just to demonstrate the flexibility
  end

  def internal_user
    admin? || current_user.clients.any?
  end

  def moderator?
    current_user.admin? || current_user.moderator_for(resource)
  end

  def public_client_ids
    Rails.cache.fetch('client_policy_public_clients', expires_in: 10.minutes) do
      Client.all.pluck(:id)
    end
  end
end
```

There is lot happening here. First we have methods that fully represent
CRUD actions on our controller `able_to_view?`, `able_to_update?`,
`able_to_delete?`. 

so our controller could look like:


```ruby
class ClientsController < ApplicationController
  NotAuthorized = Class.new(StandardError)

  rescue_from NotAuthorized do |e|
    render json: {errors: [message: "403 Not Authorized"]}, status: 403
  end

  # ...
  def show
    raise NotAuthorized policy.able_to_view?
    # ...
  end

  def edit
    raise NotAuthorized policy.able_to_update?
    # ...
  end

  def update
    raise NotAuthorized policy.able_to_update?
    # ...
  end

  def delete
    raise NotAuthorized policy.able_to_delete?
    # ...
  end
  # ...
end
```

> Dont mind that we have duplicate code in our Policy. `able_to_update?`
> and `able_to_delete?` are doing the same but it's the business
> representation that is valuable to us. If our requirements change that
> only admin can delete records we change only policy class not the
> controller.

Next interesting thing is `#public_client_ids` method. We are using
adventage of [Rails model caching](http://guides.rubyonrails.org/caching_with_rails.html). Now 
for this particular case it may seem unecessary, but let say we are
doing some really complex SQL to fetch the client ids or we call
microservice:


```ruby
class ClientPolicy
  # ...
  def public_client_ids
    Rails.cache.fetch('client_policy_public_clients', expires_in: 10.minutes) do
      body = HTTParty.get('http://my-micro-service.com/api/v1/public_cliets.json')
      JSON.parse(body)
    end
  end
  # ...
end
```

As you can see Policy Object can take care of external policy calls too.

Last this I want to show you is the `#as_json` method

Imagine you have Frontend framework that is supose to display button if
given user is able to do particular action. I've seen many times that
BE will just pass flags as `user.admin==true` or
`user.moderator_for=[1,2,3]` to Frontend and developers have to replicate
exactly same policy logic with FE framework.

What you can do instead is create current user endpoint where you
already evaluate this logic for Frontend:

```ruby
# app/controller/current_user_controller.rb
class CurrentUser < ApplicationController
  def index
    roles = {}
    roles.merge(client_policy_json) if client
    reles.merge(some_other_roles)
    render json: roles
  end

  private

  def client_policy_json
    ClientPolicy
      .new(current_user: current_user, resource: client)
      .as_json
  end

  def client
    if params[:client_id]
      Client.find(params[:client_id])
    end
  end

  def some_other_roles
    { can_display_admin_link: false }
  end
end
```

`GET /current_user?client_id=1234`

...or you can just include this roles in same call as when you retriving
client data.

The point is BE Policy objecs can really make your team life better.

## Related articles

mine:

* http://www.eq8.eu/blogs/38-rails-activerecord-relation-arel-composition-and-query-objects
* http://www.eq8.eu/blogs/39-expressive-tests-with-rspec-part-1-describe-your-tests-properly
* http://www.eq8.eu/blogs/31-simple-authentication-for-one-user-in-rails
* http://www.eq8.eu/blogs/30-pure-rspec-json-api-testing

external:

* http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
* https://github.com/elabs/pundit
