FactoryBot.define do
  factory :word_chain_walk do
    association :user
    start_char { 'あ' }
    started_at { Time.zone.local(2026, 6, 1, 10, 0, 0) }
  end
end
