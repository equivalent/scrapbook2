# Different ways how to do contextual Rails validations

Last weeks I stumble upon a discussion on "[How to add validations to a
specific instance of an active record object?][5]" and I was trying to
write an answer in few words yet that turned to this "short" article :)

Problem with Rails validations is that they are registered on a Class
level not instance level.

This means that in ideal object world we could just do this:

```ruby
# Reminder, This is not possible !!!
identity = Identity.new
identity.validations << ValidateEmailFormat.new(with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/, on: :submitted_email) 
identity.validators # => [#<ValidateEmailFormat ...>] # ...
```

...and therefore instance would just ask itself *"what are the registered
validators I have to apply"*

But in reality our validators are registered when class is registered to
the system:

```
class Identity < ActiveRecord::Base
  validates_format_of :submitted_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z
end

Identity._validators # {:submited_email=>[#<ActiveRecord::Validations::PresenceValidator:0x00000002258ff8 # ....
```

...and therefore instance is asking Class *"what are the registered validators on you that I have to apply"*

So if you try to register another validator, that will then reflect to all
instances.

In remaining part of the article we will have a look on some
alternatives how something similar can be done.

In our examples will be trying to solve this issue:

```ruby
# app/models/identity.rb
class Identity < ActiveRecord::Base
  # this should be validated all the time
  validates_presence_of :uid, :provider, :auth

  # this should be validated only in some cases
  validates_presence_of :submitted_email
  validates_format_of   :submitted_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
end
```

So we want to validate presence of `:uid` and `:provider` all the time (e.g.: model
update received via `OAuthCallbackController#create`), but we should validate `:submitted_email`
only when submitted from other controller when we prompt User to update
his record(`Identities#update`)


## `attr_accessor` as a behavior modifier

One way would be to enable `attr_accessor` in our model and we would set some
value (without writing to DB) from a controller and deal with the condition inside the model:

```ruby
# app/controllers/identities_controller.rb
class OAuthCallbackController
  def create
    @identity = Identity.new(params.slice(:uid, :provider))
    if @identity.save # will validate only :uid, :provider
      # ...
    end
  end
end

# app/controllers/identities_controller.rb
class IdentitiesController
  def update
    @identity = Identity.find(params[:id])
    @identity.attributes(params.require(:identity).permit(:submitted_email))
    @identity.editting_context = :interface
    if @identity.save   # will validate :uid, :provider and :submitted_email
      # ...
    end
  end
end

# app/model/identity.rb
class Identity < ActiveRecord::Base
  attr_accessor: :editting_context

  validates_presence_of :uid, :provider, :auth

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

  validates_presence_of :submitted_email,
    if: Proc.new{|i| i.editting_context == :interface }

  validates_format_of   :submitted_email,
    with: EMAIL_REXP,
    if:   Proc.new{|i| i.editting_context == :interface }
end
```

Problem is that this may easily get out of hand and your model will be
too fat.

!['Model too fat'](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/oop-model-too-fat.png)

## Rails built in `on:` context

Ruby on Rails has a build in way how to deal with this situations by
introducing validation context.

```ruby
# app/model/identity.rb
class Identity < ActiveRecord::Base
  EMAIL_REXP = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z

  validates_presence_of :uid, :provider, :auth

  validates_presence_of :submitted_email, on: :interface
  validates_format_of   :submitted_email, with: EMAIL_REXP, on: :interface
end

# app/controllers/oauth_callback__controller.rb
class OAuthCallbackController
  def create
    @identity = Identity.new
    @identity.attributes(params.slice(:uid, :provider))
    if @identity.save # will validate only :uid, :provider
      # ...
    end
  end
end

# app/controllers/identities_controller.rb
class IdentitiesController
  def update
    @identity = Identity.find(params[:id])
    @identity.attributes(params.require(:identity).permit(:submitted_email))
    if @identity.save(context: :interface) # will validate :uid, :provider and :submitted_email
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
    validates_presence_of :submitted_email, on: :interface
    validates_format_of   :submitted_email, with: EMAIL_REXP, on: :interface
  end
end


# app/model/identity.rb
class Identity < ActiveRecord::Base
  EMAIL_REXP = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z

  include InterfaceIdentityConcern

  validates_presence_of :uid, :provider, :auth
end
```

But placing everything into Concerns is like putting all the mess
into drawer when your Mom asks you to clean your room. It looks clean but
the mess is still there and finding stuff when you need is difficult.

It also doesn't solve the fact that you are basically using "hash map" for
controlling you use cases (which is in 90% of cases ok) but you are not using
can get quickly out of hands.

!['Model too many responsibility'](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/oop-model-too-many-responsibilities.png)

Let's have a look on some Object Oriented Solutions.

> If you are Ruby novice I'm recommending to stuck with existing conventions that were
> described above, topics bellow may feel too out of hand for untrained eye.


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
  validates_presence_of :uid, :provider
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

# app/controllers/oauth_callback_controller.rb
class OAuthCallbackController
  def update
    @identity = Identity.find(params[:id])
    @identity.attributes = params.slice(:uid, :provider)

    if @identity.save
      # ...
    end
  end
end

# app/controllers/identities_controller.rb
class IdentitiesController
  def update
    @identity = Identity.find(params[:id])
    @identity = SubmittedIdentity.new(@identity)

    # @identity.class # => SubmittedIdentity

    @identity.attributes = params.require(:identity).permit(:submitted_email)

    if @identity.save
      # ...
    end
  end
end
```

!['Controller communicating with decorated model '](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/oop-controller-comunicating-with-decorated-model.png)

The biggest benefit is that you can stack several decorators like this
and have different layers of validation

```ruby
@identity = Identity.find(params[:id])
@identity = SubmittedIdentity.new(@identity)
@identity = SomeOtherValidationIdentityDecorator.new(@identity)
@identity = AndAnotherValidationIdentityDecorator.new(@identity)
# ...
```

!['Stack up multiple validation decorators'](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/oop-model-decorated-multiple-times.png)


This may seem as ideal solution however there are some big issues with this
approach.

First of all you may stumble on the naming issue if you
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
decorator has their own separate `errors`

> This happens due to `include ActiveModel::Validations` [source here] [3]

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
on a new Identity you don't want to display errors on fields that are
not shown in the input.

The "own `errors`" problem may be also an issue if you use some other Rails gem that is
forcing itself to communicate directly with model. For example if you use
Draper gem and you try to Draper Decorate our Validation Decorator
instance it
will not recognize the `errors` on Validation Decorator:

```
@identity = Identity.new(uid: 12345, provider: 'Twitter')
@submitted_identity = SubmittedIdentity.new(@identity)

@identity.valid ?          # => true
@submitted_identity.valid? # => false

@draper_decorated_identity = @submitted_identity.decorate  # drapers IdentityDecorator
@draper_decorated_identity.vaild?      # true
@draper_decorated_identity.erros.size   # 0
@draper_decorated_identity.object.class # Identity
```

As you can see Draper will decorate itself around underlying instance of
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
careful with them and really understand what is going on and write
tests for the usecases, not only on Unit level but on integration level
as they may backfire when a Junior Developer join your team.

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

  attr_accessor :submitted_email, :identity_id

  validates_presence_of :submitted_email
  validates_format_of   :submitted_email, with: EMAIL_REXP

  def update
    if valid?
      identity
        .tap { |i| i.submitted_email = submitted_email }
        .save
    end
  end

  def identity
    @identity ||= Identity.find_by!(id: identity_id)
  end
end

# app/controllers/oauth_callback_controller.rb
class OAuthCallbackController
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

# app/controllers/identities_controller.rb
class IdentitiesController
  def update
    @service = IdentityUpdater.new.tap do |service|
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

!['Service object validations'](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/oop-service-taking-care-of-validation.png)


> NOTE: if you want to learn more on Service objects in Rails, watch
> https://www.youtube.com/watch?v=LsUx0dWikmo

Those who worked with Service objects or Processor objects know that
they sometimes may do too many tasks and placing overhead of validation
on the may be another extra complexity.

Imagine you are dealing with client who want to send to your app  API
an overly composed API request creating multiple resources. It's an
important client so you cannot say no to their request and they don't
want to allocate any time to make the request more RESTfull.

Imagine they are sending you something like this (but 20times more
complex):

```json
{
  "user": {
    "name": "Jonny",
    "email":  "blabla@test.com",
  },
  "document": {
    "url":"http://blabla.com/abc.txt" }
  }
}
```

My favorite approach to situations like this is to initialize **Request
Model** and deal with validations in it, and when valid then pass it to
service object or processor object.

```ruby
# app/requent_models/document_bulk_request_model.rb
class DocumentBulkRequestModel
  include ActiveModel::Validations

  def initialize(params)
    @params = params
  end

  validates :user_name,
    length: { maximum: 255 },
    presence: true

  validates :user_email,
    length: { maximum: 255 },
    presence: true,
    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/ }

  validates :document_url,
    length: { maximum: 1200 },
    presence: true,
    format: { with: /\Ahttp.*/ }

  def user_name
    user_params['name']
  end

  def user_email
    user_params['email']
  end

  def document_url
    document_params['url']
  end

  private
    attr_reader :params

    def user_params
      params['user'] || {}
    end

    def document_params
      params['document'] || {}
    end
end

# app/services/client_bulk_process.rb
class ClientBulkProcess
  attr_reader :request_model

  def initialize(request_model)
    @request_model = request_model
  end

  def call
    # create User with  `request_model.user_name`, `request_model.user_email`
    # create User documents with  `request_model.document_url`
    # other processing ...
  end
end
```

Then you can do:

```ruby
# app/controllers/bulk_requents_controller.rb
class BulkRequestsController.rb
  def process_client
    request_model = DocumentBulkRequestModel.new(params)

    if request_model.valid?
      ClientBulkProcess.new(request_model).call 
      # ...
    else
      render json: request_model.errors.full_messages
    end
  end
end
```
!['Request Model taking care of validations'](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/oop-request-model-service.png)

## Validator Factory

One other interesting way is tho use Validator Factory. I'm not going to
explain them here but there is a wonderful article going into depth: http://blog.lunarlogic.io/2015/models-on-a-diet/

I've never used them but they are definitely interesting concept

## Conclusion

In normal situation in 80% to 90% of cases regular Rails validations on
a model would be enough. However there are cases when keeping your
validation in a Model is counterproductive. Don't be afraid to separate
concerns and responsibilities to different objects.

My advice is don't go over board, if something can be done simple make
it simple. If the code of simple solution looks too heavy refactore.

Always make sure you write tests for your scenarios. Don't just use
[Shoulda Matchers][6] for validation. The may be enough for Model but may
kick you if you are doing something big. Try to feed the validation object multiple data, and always
write at least few integration scenarios. You don't necessary have to write
Selenium/Capybara scenario, [RSpec request spec][4] sending some faulty
prams should be enough.

> If you enjoyed the images in this article, you may find them at 
> [my DevianArt profile](http://equivalent8.deviantart.com/gallery/58024529/objects-oriented-programnig)

[1]: http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
[2]: https://github.com/drapergem/draper
[3]: https://github.com/rails/rails/blob/6dfab475ca230dfcad7a603483431c8e7a8f908e/activemodel/lib/active_model/validations.rb
[4]: https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
[5]: https://gist.github.com/thechrisoshow/2236521
[6]: https://github.com/thoughtbot/shoulda-matchers
