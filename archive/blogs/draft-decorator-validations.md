

The problem:

```ruby
# app/models/identity.rb
class Identity < ActiveRecord::Base
  # this should be validated all the time
  validates_presence_of :uid, :provider, :auth
  validates_uniqueness_of :uid, :scope => :provider

  # this should be validated only from Identity update controller
  validates_presence_of :submitted_email
  validates_format_of   :submitted_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z
end
```

So we want to validate presence and uniquenes of `:uid` all the time (e.g.: model 
update received via OAuthCallbackController), but we should validate `:submitted_email`
only when submitted from other controller when we prompt User to update
his record(`Identities#update`)


One way how to do this is to use custom validators that deals with all
the conditions that we need


Other way would be to provide `attr_accessor` and we would set some
value (without writing to DB) and deal with the condition there

```ruby
# app/controllers/identities_controller.rb
class IdentitiesController
  def update
    @identity = Identiny.find(params[:id])
    if @identity.save # will validate only :uid, :provider
      # ...
    end
  end
end

# app/controllers/admin/identities_controller.rb
class Admin::IdentitiesController
  def update
    @identity = Identiny.find(params[:id])
    @identity.editting_context = :interface
    if @identity.save(context: :admin) # will validate :uid, :provider and :submitted_email
      # ...
    end
  end
end

# app/model/identity.rb
class Identity < ActiveRecord::Base
  attr_accessor: :editting_context

  validates_presence_of :uid, :provider, :auth
  validates_uniqueness_of :uid, :scope => :provider

  validates_presence_of :submitted_email, if: :interface_context?
  validates_format_of   :submitted_email, with: EMAIL_REXP, if: :interface_context?

  def interface_context?
    editting_context_interface == :interface
  end
end

# or

# app/model/identity.rb
class Identity < ActiveRecord::Base
  attr_accessor: :editting_context

  validates_presence_of :uid, :provider, :auth
  validates_uniqueness_of :uid, :scope => :provider

  validates_presence_of :submitted_email,
    if: Proc.new{|i| i.editting_context == :interface }

  validates_format_of   :submitted_email,
    with: EMAIL_REXP,
    if:   Proc.new{|i| i.editting_context == :interface }
end
```

Problem is that this may easily get out of hand and your model will be
too fat.

<!--class Identity < ActiveRecord::Base-->
  <!--attr_accessor: :editting_context-->

  <!--validates_presence_of :uid, :provider, :auth-->
  <!--validates_uniqueness_of :uid, :scope => :provider-->

  <!--validates_presence_of :submitted_email, on: :admin-->
  <!--validates_format_of   :submitted_email, with: EMAIL_REXP, on: :admin-->
  <!--[>validates_length_of :slug, minimum: 3, unless: Proc.new{|u| u.edited_by_admin? }<]-->
  <!--[>validates_length_of :slug, minimum: 1, if:     Proc.new{|u| u.edited_by_admin? }<]-->
<!--end-->

Ruby on Rails has a bulit in way how to deal with this situations by
introducing validation context.

```ruby
# app/model/identity.rb
class Identity < ActiveRecord::Base
  EMAIL_REXP = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z

  validates_presence_of :uid, :provider, :auth
  validates_uniqueness_of :uid, :scope => :provider

  validates_presence_of :submitted_email, on: :admin
  validates_format_of   :submitted_email, with: EMAIL_REXP, on: :admin
end

# app/controllers/identities_controller.rb
class IdentitiesController
  def update
    @identity = Identiny.find(params[:id])
    if @identity.save # will validate only :uid, :provider
      # ...
    end
  end
end

# app/admin/controllers/identities_controller.rb
class Admin::IdentitiesController
  def update
    @identity = Identiny.find(params[:id])
    if @identity.save(context: :admin) # will validate :uid, :provider and :submitted_email
      # ...
    end
  end
end
```

> You can read more about validation contexts here:
> *  http://blog.arkency.com/2014/04/mastering-rails-validations-contexts/
> *  http://guides.rubyonrails.org/active_record_validations.html#on

The problem however is that this can get out of hand, and if your model
is fat, it will make it even larger.

You could deal with this issue by using [concerns][1]

```
# app/model/concerns/interface_identity_concern.rb
module InterfaceIdentityConcern
  extend ActiveSupport::Concern

  included do
    validates_presence_of :submitted_email, on: :admin
    validates_format_of   :submitted_email, with: EMAIL_REXP, on: :admin
  end
end


# app/model/identity.rb
class Identity < ActiveRecord::Base
  include InterfaceIdentityConcern

  EMAIL_REXP = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z

  validates_presence_of :uid, :provider, :auth
  validates_uniqueness_of :uid, :scope => :provider

  # ...
end

But puting everything into Concerns is like putting all the mess
into drawer when your Mom asks you to clean the room. It looks clean but
the mess is still there and finding stuff when you need is difficult.

It also doesn't solve the fact that you are basically using "hash map" for
controlling you use cases (which is in 90% of cases enough) but you are not using
real Object Oriented Solutions and that can get quickly out of hands
into developer nightmare.




## Validations on Decorator object

Another solution is to define validations on a Delegator object and then just
"decorate" the Model you are trying to apply different set of validations:

> Note if you are familiar with [Draper gem][2] meaning of the Decorator
> object decribed in this article is different.
> Decorator objects can wrap functionality around objects on different levels (in this case
> validation level)
> Draper is just really good implementation on decorating Models with
> View responsibilities.

```ruby
# app/models/identity.rb
class Identity < ActiveRecord::Base
  validates_presence_of :uid, :provider, :auth
  validates_uniqueness_of :uid, :scope => :provider
end

# app/models/submitted_identity.rb
class SubmittedIdentity < SimpleDelegator
  include ActiveModel::Validations

  validates_presence_of :submitted_email
  validates_format_of   :submitted_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z

  def save
    super if valid?
  end

  def update(*)
    raise "don't use #update use #save"
  end

  def update_attributes(*)
    raise "don't use #update_attributes use #save"
  end
end

# app/controllers/identities_controller.rb
class IdentitiesController
  def update
    @identity = Identiny.find(params[:id])
    @identity.attributes = params.require(:identity).permit(:uid, :provider)

    if @identity.save
      # ...
    end
  end
end

# app/controllers/admin/identities_controller.rb
class Admin::IdentitiesController
  def update
    @identity = Identiny.find(params[:id])
    @identity = SubmittedIdentity.new(@identity)
    # @identity.class # => SubmittedIdentity
    @identity.attributes = params.require(:identity).permit(:submitted_email)

    if @identity.save
      # ...
    end
  end
end
```

The biggest benefit is that you can stack several decorators like this
and have different layers of validation

```ruby
@identity = Identiny.find(params[:id])
@identity = SubmittedIdentity.new(@identity)
@identity = SomeOtherValidationIdentityDecorator.new(@identity)
@identity = AndAnotherValidationIdentityDecorator.new(@identity)
# ...
```

This may seem as ideal solution however there is one issue with this
approach. First of all you may stumble on the naming issue if you
do something like `My <%= @identity.class.name %>` in your views, as
your instance variable `@identity` is class `SubmittedIdentity`.

This should not be an issue if you do some name method delegation as a part of
this class, but I don't want to get too deep into that in this article.
Point is there are ways how to get around limitations of this approach.

e.g.: 

```ruby
# app/model/submitted_identity.rb
class SubmittedIdentity < SimpleDelegator
  # ...

  def model_name
    __getobj__.class.name
  end
end
```

`My <%= @identity.model_name %>`

Another issue is that the `@errors` instance_variable is defined on the
instance level of the decorator class, meaning that the model and the
decorator has their own separate `@instance.errors`

> This happens due to `include ActiveModel::Validations` [source here][3]

Therefore if you do:

```ruby
@identity = Identity.new
@submitted_identity = SubmittedIdentity.new(@identity)

@identity.valid ?          # => false
@submitted_identity.valid? # => false

@identity.errors.size            # => 2    ...errors on :uid, :provider
@submitted_identity.errors.size  # => 1    ...errors on :submitted_email
```

So the question really is if this is a bug or a feature for the
particular usecase that you need. For example when submitting Rails form
on a New Identity you don't want to display errors on fields that are
not shown in the input.

This may be also a problem if you use some other Rails gem that is
forcing itself to comunicate directly with model. For example if you use
Draper gem and you try to Draper Decorate our Validation Decorator it
will not recognize the `errors` on Validation Decorator:

```
@identity = Identity.new(uid: 12345, provider: 'Twitter')
@submitted_identity = SubmittedIdentity.new(@identity)

@identity.valid ?          # => true
@submitted_identity.valid? # => false

@draper_decorated_identity = @submitted_identity.decorate  # drapers IdentityDecorator
@draper_decorated_identity.vaild ?      # true
@draper_decorated_identity.erros.size   # 0
@draper_decorated_identity.object.class # Identity
```

As you can see Draper will decorate itself around undelying instance of
`Identity` not `SubmittedIdentity`

So in this case you need to have all the errors brought together you
need something like this:

```ruby
class SubmittedIdentity < SimpleDelegator
  include ActiveModel::Validations

  validates_presence_of :submitted_email
  validates_format_of   :submitted_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z

  def valid?
    result = super
    errors.each do |e|
      __getobj__.errors.add e
    end
    result
  end

  def save
    super if valid?
  end

  def update(*)
    raise "don't use #update use #save"
  end

  def update_attributes(*)
    raise "don't use #update_attributes use #save"
  end
end
```

This will sync up errors from the `SubmittedIdentity` object to `Identity`

```
@identity = Identity.new(uid: 12345, provider: 'Twitter')
@submitted_identity = SubmittedIdentity.new(@identity)
@draper_decorated_identity = @submitted_identity.decorate
@draper_decorated_identity.vaild ?      # false
@draper_decorated_identity.erros.size   # 1
@draper_decorated_identity.object.class # Identity
```

Decorator Validation objects are handy and quick to introduce but you need to be really
carefull with them and really understand what is going on and write
tests for the uscases not only on Unit level but on integration level
as the may backfire when a Junior Developer join your team.

## Separate Validation object

Other way to deal with this is to have the validations on a separate
object. Basically your model will stay validation free and you call
`valid?` on external object. This way your for example your `service object`
holds the validations:



```ruby
# app/model/identity.rb
class Identity < ActiveRecord::Base
  # nice thin model doing other improtant model stuff
end

# app/services/oauth_identity_creator.rb
class OauthIdentityCreator
  include ActiveModel::Validations

  attr_accessor :uid, :provider

  validates_presence_of :uid, :provider, :auth
  validates_uniqueness_of :uid, :scope => :provider

  def create
    if valid?
      identity
        .tap do |i|
          i.uid = uid
          i.provider = provider
        end
        .save
    end
  end

  def identity
    @identity ||= Identity.new
  end
end

# app/services/identity_updater.rb
class IdentityUpdater
  include ActiveModel::Validations

  attr_accessor :submitted_identity, :identity_id

  validates_presence_of :submitted_email, if: :interface_context?
  validates_format_of   :submitted_email, with: EMAIL_REXP, if: :interface_context?

  def update
    identity
      .tap { |i| i.submitted_email = submitted_email }
      .save
  end

  def identity
    @identity ||= Identity.find_by!(id: identity_id)
  end
end

```ruby
# app/controllers/identities_controller.rb
class IdentitiesController
  def create
    @service = OauthIdentityCreator.new.tap do |service|
      service.uid      = params[:auth][:uid]
      service.provider = params[:auth][:provider]
    end

    if @service.create
      @identity = @service.identity
      # ...
    else
      render json: service.errors.full_messages
    end
  end
end

# app/controllers/admin/identities_controller.rb
class Admin::IdentitiesController
  def update
    @service = OauthIdentityCreator.new.tap do |service|
      service.submitted_email = params[:auth][:submitted_email]
      service.identity_id     = params[:id]
    end

    if @service.update
      @identity = @service.identity
      # ...
    else
      render json: service.errors.full_messages
    end
  end
end
```

> if you want to leart more on Service objects in Rails, watch
> https://www.youtube.com/watch?v=LsUx0dWikmo









  <!--validates_each :first_name, :last_name do |record, attr, value|-->
    <!--record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z-->
  <!--end-->








> One other way is tho usevalidation factory objects: http://blog.lunarlogic.io/2015/models-on-a-diet/


gg
answer https://gist.github.com/thechrisoshow/2236521`


[1]: http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
[2]: https://github.com/drapergem/draper
[3]: https://github.com/rails/rails/blob/6dfab475ca230dfcad7a603483431c8e7a8f908e/activemodel/lib/active_model/validations.rb
