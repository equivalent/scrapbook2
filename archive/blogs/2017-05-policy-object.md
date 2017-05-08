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

## Geting complex




