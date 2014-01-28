```
bundle outdated  # list of outdated gems
bundle update    # update all gems
bundle update rails  #update rails gem
```



# creating own gem

### version

```ruby
#  lib/my_gem/version.rb
# encoding: utf-8

module MyGem
  module VERSION
    MAJOR = 0
    MINOR = 11
    PATCH = 1
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.');
  end
end
```

stolen from: https://github.com/peter-murach/github/blob/master/lib/github_api/version.rb

