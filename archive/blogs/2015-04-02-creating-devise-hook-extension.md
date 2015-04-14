




```
# vim devise_security_extension.gemspec


```ruby
# lib/devise_security_extension/paranoid_verification.rb

require 'devise_security_extension/hooks/paranoid_verification'

module Devise
  module Models
    module ParanoidVerification
      extend ActiveSupport::Concern

      def need_paranoid_verification?
        true
      end
    end
  end
end
```

```ruby

    def handle_paranoid_verification
      if !devise_controller? && !request.format.nil? && request.format.html?
        Devise.mappings.keys.flatten.any? do |scope|
          if signed_in?(scope) && warden.session(scope)['paranoid_verify']
            session["#{scope}_return_to"] = request.path if request.get?
            redirect_for_paranoid_verification scope
            return
          end
        end
      end
    end
```


```
warden.session
=> {"paranoid_verify"=>true,
 "last_request_at"=>1427982850,
 "password_expired"=>false,
 "unique_session_id"=>"g5_sts7ru1PKV5L_6KKL"}
```

update Gempspec

#...
Gem::Specification.new do |s|
#...
  s.files = [
   #...
   "lib/devise_security_extension/hooks/paranoid_verification.rb",
   #...
  ]
end
```


