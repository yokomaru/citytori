require 'rails_helper'

RSpec.describe 'StartWalk', type: :system do
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

  scenario '位置情報を取得できた場合は散歩を開始できる' do
    log_in(user)

    visit root_path

    begin
      set_browser_geolocation(35.6586, 139.7454)

      click_button '始める'

      within 'dialog[data-walk-start-target="modal"][open]' do
        expect(page).to have_content('位置情報を取得できました')
        click_button '散歩を始める'
      end

      expect(page).to have_content('しりとり散歩中')
      expect(user.word_chain_walks.count).to eq(1)
    ensure
      page.driver.browser.execute_cdp('Emulation.clearGeolocationOverride')
    end
  end

  scenario '位置情報を取得できなかった場合でも散歩を開始できる' do
    log_in(user)

    visit root_path

    begin
      set_failure_browser_geolocation

      click_button '始める'

      within 'dialog[data-walk-start-target="modal"][open]' do
        expect(page).to have_content('位置情報を取得できませんでした')
        click_button '位置情報なしで散歩を始める'
      end

      expect(page).to have_content('しりとり散歩中')
      expect(user.word_chain_walks.count).to eq(1)
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

  def set_failure_browser_geolocation
    page.driver.browser.execute_cdp(
      'Emulation.setGeolocationOverride'
    )
  end
end
