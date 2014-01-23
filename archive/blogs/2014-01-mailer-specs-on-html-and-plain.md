



```ruby
# spec/support/mailer_helpers.rb
module MailerHelpers
  def get_plain_body(mailer_instance)
    mailer_instance.body.encoded.split(/\nContent-Type/)[1]
  end

  def get_html_body(mailer_instance)
    mailer_instance.body.encoded.split(/\nContent-Type/)[2]
  end
end
```

The `\n` is preventing split failing if you use proper mail layout file

```haml
# app/view/layouts/mail.html.haml
#...
%meta{:content => "text/html; charset=utf-8", "http-equiv" =>"Content-Type"}/
#...
```

Some of you may know about [HTML
boilerplate](http://html5boilerplate.com/), well there is also [HTML Email
Boilerplate](http://htmlemailboilerplate.com/) and I recommend you to
implement code from it to your email layout.

```ruby
# spec/mailers/reset_password_instructions_spec.rb

require "spec_helper"

include MailerHelpers

describe Devise::Mailer do
  describe "#reset_password_instructions" do
    let(:user)  { build :user }
    let(:token) { '123c' }

    let(:mail) { described_class.reset_password_instructions(user, token) }
    let(:plain_body) { get_plain_body mail }
    let(:html_body)  { get_html_body  mail }

    it "mail subject should tell me that I'm resetting password" do
      mail.subject.should match(/Reset password instructions/)
    end

    # depends on your business rules
    it 'sender should be admin' do
      mail.sender.should match(/\Aequivalent@eq8.eu\z/)
      mail.from.should include('equivalent@eq8.eu')
    end

    it 'recipient should be user' do
      mail.to.should include user.email
    end

    %w(plain_body html_body).each do |type|
      describe type.humanize do
        subject { send(type) }

        it 'should greet user' do
          should match(/Hello #{user.email}/)
        end

        it 'should tell him that reset password was triggerd' do
          should match(/requested a link to change your password/)
        end

        it 'should contain invitation link with token' do
          should match(/http:\/\/www.eq8.eu\/users\/password\/edit\?reset_password_token=123c/)
        end
      end
    end

    it 'html body should contain link for reseting password' do
      html_body.should have_selector 'a', text: 'Change my password'
    end

  end
end
```
