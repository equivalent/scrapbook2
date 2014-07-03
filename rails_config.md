# ruby configuration hash

```ruby
config = Hash.new do |h,k|
  h[k] = Hash.new(&h.default_proc)
end

config[:production][:database][:adapter] = 'mysql'
config[:production][:database][:adapter] # => "mysql"
```
source: ruby tapas 032

# How to override gem template in Rails 

let say you have gem like [Draper](https://github.com/drapergem/draper) or [Pundit](https://github.com/elabs/pundit) and you want to override their generator templates in your Rails appplication

you have to create template files in: `lib/templates/gem_name/generator_name/generator_template_file_name`

`lib/templates/pundit/policy/policy.rb` for https://github.com/elabs/pundit/blob/master/lib/generators/pundit/policy/templates/policy.rb

`lib/templates/rails/decorator/decorator.rb` for https://github.com/drapergem/draper/blob/master/lib/generators/rails/templates/decorator.rb


http://stackoverflow.com/questions/21732373/how-to-override-gem-generator-template-in-rails-app/21732673?noredirect=1#comment32876897_21732673


# Silence rails cache log

    # config/enviroment.rb
    Rails.cache.silence!

Rails: 3.2.13

Published 19.09.2013




# load YAML file config  only for development

config 

```ruby
# config/local_config.rb
begin
  LOCAL_CONFIG = YAML.load_file("#{Rails.root}/config/local_config.yml")[Rails.env] || {}
rescue
  Rails.logger.warn "No config/local_config.yml not found"
  LOCAL_CONFIG = {}
 end
``` 

yml file

```yaml
# config/initializers/local_config.yml
development:
  email: 'equivalent@eq8.eu'
```

in model

    LOCAL_CONFIG.try(:[], 'email')


date: 2013-02-22
keys: enviroment, yaml configuration, 

