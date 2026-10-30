require 'rails_helper'

RSpec.describe 'Notice toast', type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider, uid: user.uid,
      info: { email: user.email, name: user.name }
    )
    visit '/auth/google_oauth2/callback'
  end

  scenario 'ログインのnoticeはトーストとして表示され自動で消える' do
    expect(page).to have_css('#notice.notice-toast [role="status"]', text: 'ログインしました。')
    expect(page).to have_no_css('#notice', wait: 7)
  end

  scenario '通知は閉じるボタンでも消せる' do
    find('button[aria-label="通知を閉じる"]').click
    expect(page).to have_no_css('#notice')
  end

  scenario 'Turboでことばを記録したnoticeも自動で消える' do
    walk = FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
    visit word_chain_walk_path(walk)
    attach_file('word_chain_walk_step_image', Rails.root.join('spec/fixtures/files/480x320.png'), make_visible: true)
    within 'dialog[open]' do
      fill_in '見つけたことば', with: 'りんご'
      click_button '写真とことばを記録する'
    end
    expect(page).to have_css('#notice.notice-toast', text: 'ことばを記録しました。')
    expect(page).to have_no_css('#notice', wait: 7)
    expect(page).to have_css('#latest_step', text: 'りんご')
  end
end
