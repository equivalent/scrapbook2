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

