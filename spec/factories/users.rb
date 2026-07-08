FactoryBot.define do
  factory :user do
    provider { 'google_oauth2' }
    uid { SecureRandom.uuid }
    sequence(:email) { |n| "user#{n}@example.com" }
    name { 'テストユーザー' }
  end
end
