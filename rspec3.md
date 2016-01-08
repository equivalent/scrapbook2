# after create trait

```
    trait :with_media do
      after :create do |work|
        FactoryGirl.create :media, work: work
      end
    end
```

# notes from RSpce 3 meetup London Dec 2014

skillmasters meetup

* Rspeec ~> 2.99
* transpec gem can help you upgrade
*
 
```
instance_double(Foo, cell: xx)
class_double
object_double 

# composed matchers
expect(json).to match("foo" => 'bar", "x"=>{y:z}

RSpec.descirbe 'Foo' do
  describe 'du stuff' do
  end
end
```

RSpec 3 with combination with rails has `spec_helper` and `rails_helper`


# stub

```
    allow(object).to receive(:message) { 'abcd' }
    allow_any_instance_of(Api::Austria::Requests).to receive(:init_auth_uri) { 'https://foo-bar.test/digest-webmocks-hack' }

```
