require 'rails_helper'

RSpec.describe 'StartWalk', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { FactoryBot.create(:user) }

  scenario '位置情報を取得できた場合は散歩を開始できる' do
    log_in(user)

    visit root_path

    begin
      set_browser_geolocation(35.6586, 139.7454)

      first(:button, 'しりとり散歩をはじめる').click

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

      first(:button, 'しりとり散歩をはじめる').click

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
end
