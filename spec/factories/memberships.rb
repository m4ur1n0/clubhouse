FactoryBot.define do
  factory :membership do
    association :user
    association :club
  end
end
