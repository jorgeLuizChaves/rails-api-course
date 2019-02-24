FactoryBot.define do
  factory :comment do
    content { "my content" }
    association :user
    association :article
  end
end
