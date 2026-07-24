require 'rails_helper'

RSpec.describe 'WordChainWalks', type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { FactoryBot.create(:user) }

  let(:word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
  end

  let(:word_chain_walk_step) do
    FactoryBot.create(
      :word_chain_walk_step,
      :with_image,
      word_chain_walk: word_chain_walk,
      word: 'りんご',
      memo: '赤いりんご'
    )
  end

  def log_in(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: user.provider,
        uid: user.uid,
        info: {
          email: user.email,
          name: user.name
        }
      )

    visit '/auth/google_oauth2/callback'
  end

  def attach_step_image
    attach_file '写真', Rails.root.join('spec/fixtures/files/480x320.png')
  end

  def fill_in_step_form(word:, memo: '見つけた言葉のメモ')
    fill_in '見つけた言葉', with: word
    fill_in 'メモ', with: memo
    attach_step_image
  end
end
