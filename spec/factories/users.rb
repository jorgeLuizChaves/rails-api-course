FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "ash-#{n}@ash.com" }
    sequence(:name) { |n| "ash-#{n}" }
    sequence(:url) { |n| "ash-url-#{n}" }
    sequence(:avatar_url) { |n| "ash-url-avatar-#{n}" }
    sequence(:provider) { |n| "github" }
  end
end
