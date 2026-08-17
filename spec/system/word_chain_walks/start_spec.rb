require 'rails_helper'

RSpec.describe 'Start', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { FactoryBot.create(:user) }

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

  scenario 'しりとり散歩開始時に開始地点の位置情報の取得ができた場合保存されること' do
    log_in(user)

    visit root_path

    begin
      set_browser_geolocation(35.6586, 139.7454)

      click_button '始める'

      expect(page).to have_content('しりとり散歩中')

      created_word_chain_walk = user.word_chain_walks.order(:id).last

      expect(created_word_chain_walk.start_latitude).to  eq(35.6586)
      expect(created_word_chain_walk.start_longitude).to eq(139.7454)
    ensure
      page.driver.browser.execute_cdp('Emulation.clearGeolocationOverride')
    end
  end

  def set_browser_geolocation(latitude, longitude, accuracy: 100)
    page.driver.browser.execute_cdp(
      'Emulation.setGeolocationOverride',
      latitude:,
      longitude:,
      accuracy:
    )
  end
end
