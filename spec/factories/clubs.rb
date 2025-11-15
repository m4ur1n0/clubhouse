FactoryBot.define do
  factory :club do
    association :user
    sequence(:name) { |n| "Club #{n}" }
    description { "A sample club." }
  end
end
