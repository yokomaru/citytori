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
      expect(user.word_chain_walks.count).to eq(1)

      created_word_chain_walk = user.word_chain_walks.order(:id).last
      expect(created_word_chain_walk.start_latitude).to  eq(35.6586)
      expect(created_word_chain_walk.start_longitude).to eq(139.7454)
    ensure
      page.driver.browser.execute_cdp('Emulation.clearGeolocationOverride')
    end
  end

  scenario 'しりとり散歩開始時に開始地点の位置情報の取得ができなかった場合、そのまま進める場合は開始地点の位置情報はnilで保存されること' do
    log_in(user)

    visit root_path

    begin
      set_failure_browser_geolocation

      accept_confirm("位置情報を取得できませんでした。このまま開始の位置情報なしで進めますか？") do
        click_button '始める'
      end

      expect(page).to have_content('しりとり散歩中')
      expect(user.word_chain_walks.count).to eq(1)

      created_word_chain_walk = user.word_chain_walks.order(:id).last

      expect(created_word_chain_walk.start_latitude).to be_nil
      expect(created_word_chain_walk.start_longitude).to be_nil
    ensure
      page.driver.browser.execute_cdp('Emulation.clearGeolocationOverride')
    end
  end

  scenario 'しりとり散歩開始時に開始地点の位置情報の取得ができなかった場合、進めない場合はしりとり散歩自体が作成されないこと' do
    log_in(user)

    visit root_path

    begin
      set_failure_browser_geolocation


      accept_alert("電波状況や権限を見直して再度開始ボタンを押してください") do
        dismiss_confirm("位置情報を取得できませんでした。このまま開始の位置情報なしで進めますか？") do
          click_button '始める'
        end
      end


      expect(user.word_chain_walks.count).to eq(0)
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
      'Emulation.setGeolocationOverride',
    )
  end
end
