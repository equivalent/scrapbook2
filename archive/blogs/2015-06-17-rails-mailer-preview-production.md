


From Rails 4.2 you can use the flag in productiontion.rb (or other
custom enviroment):

```ruby
# config/environments/production.rb
# ...
config.action_mailer.show_previews = true
```

I haven't found anything similar in Rails 4.1.



sources 

* https://richonrails.com/articles/action-mailer-previews-in-ruby-on-rails-4-1
* http://stackoverflow.com/questions/27453578/rails-4-email-preview-in-production
* http://guides.rubyonrails.org/4_1_release_notes.html
* http://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails
