# Add custom Exception

    # gem_dir/lib/gem_name/exceptions.rb
    module Exceptions
      class AuthenticationError < StandardError; end
      class InvalidUsername < AuthenticationError; end
    end
    
    raise Exception::InvalidUsername
    
if you want default message

    class WrongDocumentStatus < StandardError
      def initialize(msg='Unknown status for Document')
        super
      end
    end

sources: 

* http://stackoverflow.com/questions/5200842/where-to-define-custom-error-types-in-ruby-and-or-rails
* http://stackoverflow.com/questions/3382866/rubys-exception-error-classes

Rails: 3.2.13

Published: 19.09.201



# Rake task to list all exceptions

```ruby
# lib/tasks/exceptions.rake
namespace :exceptions do
  task :list => :environment do
    exceptions = []

    ObjectSpace.each_object(Class) do |k|
      exceptions << k if k.ancestors.include?(Exception)
    end

    puts exceptions#.sort { |a,b| a.name.to_s <=> b.name.to_s }.join("\n")
  end
end
```

sources: 

* http://stackoverflow.com/questions/6521544/getting-a-list-of-existing-rails-error-classes-for-re-use-inheritance/8961954#8961954

Rails: 3.2.13

Published: 19.09.2013
