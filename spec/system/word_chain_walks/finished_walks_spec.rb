require 'rails_helper'

RSpec.describe 'FinishedWalks', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { FactoryBot.create(:user) }
  let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, user: user, start_char: 'り') }

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

  scenario '完了済みの散歩でタイムラインと地図を切り替えられる' do
    log_in(user)

    FactoryBot.create(
      :word_chain_walk_step,
      :with_image,
      word_chain_walk: word_chain_walk,
      word: 'りんご',
      latitude: 35.6586,
      longitude: 139.7454
    )

    word_chain_walk.update!(finished_at: Time.current)

    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_content('タイムライン')
    expect(page).to have_content('りんご')

    click_link '地図'

    expect(page).to have_content('地図')
    expect(page).to have_css('[data-controller="walk-map"]')
  end

  scenario '地図のマーカーをクリックすると対応する記録の情報が表示される' do
    log_in(user)

    step = FactoryBot.create(
      :word_chain_walk_step,
      :with_image,
      word_chain_walk: word_chain_walk,
      word: 'りんご',
      latitude: 35.6586,
      longitude: 139.7454
    )

    word_chain_walk.update!(finished_at: Time.current)

    visit map_word_chain_walk_path(word_chain_walk)

    within '#walk-map-container' do
      find("a[href='#{word_chain_walk_word_chain_walk_step_path(word_chain_walk, step)}']").click
    end

    within '#selected_walk_step' do
      expect(page).to have_content('りんご')
    end
  end

  scenario '地図のピンを押して表示されたカードから記録の詳細画面に移動できる' do
    log_in(user)

    step = FactoryBot.create(
      :word_chain_walk_step,
      :with_image,
      word_chain_walk: word_chain_walk,
      word: 'りんご',
      latitude: 35.6586,
      longitude: 139.7454
    )

    word_chain_walk.update!(finished_at: Time.current)

    visit map_word_chain_walk_path(word_chain_walk)

    step_path = word_chain_walk_word_chain_walk_step_path(word_chain_walk, step)

    within '#walk-map-container' do
      find("a[href='#{step_path}']").click
    end

    within '#selected_walk_step' do
      click_link 'りんご'
    end

    expect(page).to have_current_path(step_path)
    expect(page).to have_content('りんご')
  end
end
