    

# Factories with [FactoryGirl](https://github.com/thoughtbot/factory_girl)




```ruby
FactoryGirl.define do
  factory :country do
    name "Tomi-land"
    existing true
    short_description  Faker::Lorem.paragraph  # With Faker gem

    association: :client                # 1:M relation, will use factory :client
    association: :contentable, factory: [:content, published: true]
    
    sequence(:long_description) { |n| "Country description no #{n}." }
    
    trait :used_in_address do
      address_ids { [FactoryGirl.create(:address).id] }
    end
    
    trait :cached_in_past do
      after :create do |country|
        country.update_column :cached_at, 2.days.ago
      end
    end
    
    trait :bombarded do
      after :create do |country|
        user.bombings << FactoryGirl.create(:bombing, country: country)
      end
    end
  end
    
  factory :vanished_country, class: 'Country' do
    existing false
    
    after :build do |country|
      country.do_something_meaningful
    end
  end
  
end

# call with traits
FactoryGirl.create :country, :cached_in_past, cities: [city1, city2], short_description: 'my desc'
```



### Ignored transient

```ruby
FactoryGirl.define do
  factory :validation_type do
    sequence(:name) {|n| "Type #{n}"}
    association :tld
  end

  trait :with_fields do
    transient do                           # ignore in older version
      number_of_fields 1
    end

    after(:create) do |validation_type, evaluator|
      create_list(:field, evaluator.number_of_fields, validation_type: validation_type, input_type: 'text')
    end
  end

  trait :with_validations do
    transient do                           # ignore in older version
      number_of_validations 1
    end

    after(:create) do |validation_type, evaluator|
      create_list(:validation, evaluator.number_of_validations, validation_type: validation_type)
    end
  end

end

FactoryGirl.create :validation_type, :with_fields, :number_of_fields => 4
```


### Creating multiple factories (factory_list)

    FactoryGirl.create_list(:full_application, 3)  # will create 3 applications





### goodnight reading:

* https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
* http://arjanvandergaag.nl/blog/factory_girl_tips.html


rails 3.2.12
