#Devise gem




### Devise failture app responding to JS reqest


if you use RJS (`js` format Rails calls) you may find that Devise
responds  with non JS response when 401 - not authenticated

```ruby
# config/initializers/devise.rb
class CustomFailureApp < Devise::FailureApp
  def http_auth_body
    case request_format
    when :js, 'js'
      'alert(" not authorized !");'
    when :json, 'json'
      { error: i18n_message }
    else
      i18n_message
    end
  end
end

Devise.setup do |config|
  # ...
  config.warden do |manager|
    manager.failure_app = CustomFailureApp
  end
  # ...
end
```


<https://gist.github.com/equivalent/385bdc3b788b484ade0bdf9cc23ad584>
