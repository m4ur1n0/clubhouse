FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Test User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:google_id) { |n| "google-#{n}" }
    avatar_url { "https://example.com/avatar.png" }
  end
end
