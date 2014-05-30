# Translating locales for Rails model errors

As you may know you can specify own message for Rails model validation error
like this: 

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  PASSWORD_FORMAT = /\A.*(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*\z/

  validates_format_of :password, :with => PASSWORD_FORMAT,
    message: "Must include uppercase & number"

end
```

...which is good until your application reach the stage 
when you want to support multiple languages.

I've seen some developers do something like this:

```ruby
# app/models/user.rb
  # ...
  validates_format_of :password, :with => PASSWORD_FORMAT,
    message: I18n.t('wrong_password')
  # ...
end
```

...which is kinda acceptable if you doing something super-ninja like,
but for 99% of cases there is already built in Rails solution, so
why not to use it:


```ruby
# app/models/user.rb
  # ...
  validates_format_of :password, :with => PASSWORD_FORMAT,
  # ...
```

```yaml
# config/locales/en.yml
en:
  activerecord:
    errors:
      models:
        user:
          attributes:
            password:
              invalid: 'Must include uppercase & number'
```

* for `validates_presence_of` keyword you can use `blank`
* for `validates_length_of` keyword you can use `too_short` or `too_long`
* for `validates_uniqueness_of` keyword you can use `taken`

You can find other keys in this [Rails error message interpolation table](http://guides.rubyonrails.org/i18n.html#error-message-scopes)

As demonstrated in official [Active Record locales guide](http://guides.rubyonrails.org/i18n.html#error-message-scopes)
there is a certain locales fallback tree for Active Record:

```ruby
activerecord.errors.models.admin.attributes.name.blank
activerecord.errors.models.admin.blank
activerecord.errors.models.user.attributes.name.blank
activerecord.errors.models.user.blank
activerecord.errors.messages.blank
errors.attributes.name.blank
errors.messages.blank
```

You can use it for example if you want certain translation to apply on attribute
`password` for all models:

```yaml
# config/locales/en.yml
en:
  errors:
   attributes:
     password:
       invalid: 'Wrong password format !!'
```

One interesting thing I discovered is that for this to work `errors`
key must be before `activerecord` key in your locales file otherwise they
 wont work. But I'm not 100% sure on that (may be caused one of gems I
use in the project):

```yaml
# config/locales/en.yml
en:
  errors:
   attributes:
     # ...
  activerecord:
    # ...  
```

For those that need more flexibility there is option to specify your
own symbols (as demonstrated in [this SO answer](http://stackoverflow.com/a/4452202) )

```ruby
# app/models/user.rb
  # ...
  validates_format_of :password, :with => PASSWORD_FORMAT,
    message: :foo
  # ...
```

which will point to:
`en.activerecord.errors.models.user.attributes.password.foo`


```yaml
# config/locales/en.yml
en:
  activerecord:
    errors:
      models:
        user:
          attributes:
            password:
              foo: "Are U bannanas ? O_O"
```

...same fallback rules should apply.


source:

* http://stackoverflow.com/questions/4451076/rails-internationalization-i18n-in-model-validations-possible-or-not
* http://guides.rubyonrails.org/i18n.html#translations-for-active-record-models

published: 2014-05-29

keywords: I18n, locales, internationalization, Ruby on Rails 4, Rails 3,
Ruby 2.1.1, models, errors

