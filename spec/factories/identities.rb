# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identity do
    user
    provider 'facebook'
    sequence(:uid) { |i| "1234#{i}" }
  end
end
