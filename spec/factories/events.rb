FactoryBot.define do
  factory :event do
    association :club
    association :user
    sequence(:name) { |n| "Event #{n}" }
    date { Time.current + 1.day }
    location { "Campus" }
    description { "Practice" }

    users_attending { [].to_json }
  end
end
