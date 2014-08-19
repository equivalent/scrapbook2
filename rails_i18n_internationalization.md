http://edgeguides.rubyonrails.org/i18n.html


## pick / Change format type

```ruby
 helper.l Time.now.to_date
 => "2014-08-19"
 
 helper.l Time.now.to_date, format: :long
 # => "August 19, 2014" 
 ```

## Get current locale (language)

```
I18n.locale
```

### translate array


```ruby
# app/model/validation.rb
class Validation
  STATUSES = %w(Pass Fail)
end  
```

```yaml
# config/locales/en.yml
en:
  something_something:
    validation
      statuses: 
        Pass: 'yes'
        Fail: 'NOOO!'
```

```haml
= t(Validation::STATUSES, scope: 'something_something:validation:statuses'

will render ['yes', 'NOOO!']
```
  
source: http://stackoverflow.com/questions/12341231/rails-how-to-i18n-an-array-of-strings
  
### Variables

... or sprintf syntax

```haml
-# app/views/home/index.html.erb
=t 'foo.greet_username', user: "Bill", message: "Goodbye"
```

```yaml
# config/locales/en.yml
en:
  foo
    greet_username: "%{message}, %{user}!"
```
