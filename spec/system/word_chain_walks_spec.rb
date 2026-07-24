require 'rails_helper'

RSpec.describe 'WordChainWalks', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
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

  scenario 'モーダルからステップを登録できること' do
    log_in(user)

    visit word_chain_walk_path(word_chain_walk)
    click_button '写真を撮る'

    expect(page).to have_css(
      'dialog[data-modal-target="modal"][open]'
    )

    fill_in '見つけた言葉', with: 'りんご'
    fill_in 'メモ', with: 'メモ'
    attach_file '写真', Rails.root.join('spec/fixtures/files/480x320.png')

    click_button '登録する'

    within '#word_chain_walk_steps' do
      expect(page).to have_content('りんご')
    end

    expect(page).to have_css(
      '#word_chain_walk_target',
      text: 'ご'
    )

    expect(page).to have_no_css(
      'dialog[data-modal-target="modal"][open]'
    )
  end
end
