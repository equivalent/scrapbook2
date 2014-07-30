# Rails deliver mail to local file 

If you want to debug mail deliveries in development mode and want to see what exactly will be sent
you can tell Rails to "deliver" emails to local folder file instead of sending them via `sendmail` or `smtp`.

```ruby
# config/environments/development.rb
MyApp::Application.configure do
  # ...
  config.action_mailer.delivery_method = :file
  ActionMailer::Base.file_settings = { :location => Rails.root.join('tmp/mail') }
  # ...
```

In Rails 4.2 there is even better solution "Mail Previews" (... or `show_previews`)
more info http://edgeguides.rubyonrails.org/4_2_release_notes.html#action-mailer

But still if you want ho have the raw mail output, this is still valid solution.

source:

* http://api.rubyonrails.org/classes/ActionMailer/Base.html
* http://stackoverflow.com/questions/3763735/rails-mailer-sending-emails-to-a-local-file

keywords: Ruby on Rails 3, Rails 4, Rails 4.1, ActionMailer file
