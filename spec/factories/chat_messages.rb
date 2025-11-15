FactoryBot.define do
  factory :chat_message do
    association :club
    association :user
    content { "Hello club" }
  end
end
