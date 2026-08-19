require 'rails_helper'

RSpec.describe 'Finish', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { FactoryBot.create(:user) }

  let(:word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
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

  scenario 'しりとり散歩終了時に終了地点の位置情報の取得ができた場合、その位置情報が保存されること' do
    log_in(user)

    visit word_chain_walk_path(word_chain_walk)

    begin
      set_browser_geolocation(35.6586, 139.7454)

      accept_confirm('しりとり散歩をおしまいにしますか？') do
        click_button 'しりとり散歩をおしまいにする'
      end

      expect(page).to have_content('しりとり散歩が完了しました')

      word_chain_walk.reload

      expect(word_chain_walk.finished?).to be true
      expect(word_chain_walk.finish_latitude).to eq(35.6586)
      expect(word_chain_walk.finish_longitude).to eq(139.7454)
    ensure
      page.driver.browser.execute_cdp('Emulation.clearGeolocationOverride')
    end
  end

  scenario 'しりとり散歩終了時に終了地点の位置情報の取得ができなかった場合、そのまま進める場合は終了地点の位置情報はnilで保存されること' do
    log_in(user)

    visit word_chain_walk_path(word_chain_walk)

    begin
      set_failure_browser_geolocation

      expect do
        accept_confirm('位置情報を取得できませんでした。このまま位置情報なしで進めますか？') do
          accept_confirm('しりとり散歩をおしまいにしますか？') do
            click_button 'しりとり散歩をおしまいにする'
          end
        end
        expect(page).to have_content('しりとり散歩が完了しました')
      end.to change { word_chain_walk.reload.finished? }.from(false).to(true)

      expect(word_chain_walk.finish_latitude).to be_nil
      expect(word_chain_walk.finish_longitude).to be_nil
    ensure
      page.driver.browser.execute_cdp('Emulation.clearGeolocationOverride')
    end
  end

  scenario 'しりとり散歩終了時に終了地点の位置情報の取得ができなかった場合、進めない場合は散歩は完了しないこと' do
    log_in(user)

    visit word_chain_walk_path(word_chain_walk)

    begin
      set_failure_browser_geolocation

      accept_alert("電波状況や権限を見直して再度ボタンを押してください") do
        dismiss_confirm("位置情報を取得できませんでした。このまま位置情報なしで進めますか？") do
          accept_confirm("しりとり散歩をおしまいにしますか？") do
            click_button "しりとり散歩をおしまいにする"
          end
        end
      end

      expect(word_chain_walk.reload.finished?).to be false
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
