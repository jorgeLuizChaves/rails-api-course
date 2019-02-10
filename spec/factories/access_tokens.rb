FactoryBot.define do
  factory :access_token do
    sequence(:token) { |n| "token-#{n}" }
    user { build :user }
  end
end
