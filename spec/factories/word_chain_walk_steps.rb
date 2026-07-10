FactoryBot.define do
  factory :word_chain_walk_step do
    word { 'あいうえお' }
    association :word_chain_walk

    trait :with_image do
      after(:build) do |step|
        step.image.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/480x320.png')),
          filename: 'sample.png',
          content_type: 'image/png'
        )
      end
    end
  end
end
