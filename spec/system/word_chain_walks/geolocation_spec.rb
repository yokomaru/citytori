require 'rails_helper'

RSpec.describe 'Geolocation', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let(:user) { FactoryBot.create(:user) }
  let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, user: user, start_char: 'り') }

  scenario 'キャンセル後に届いた位置情報は反映されない' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    page.execute_script <<~JS
      navigator.geolocation.getCurrentPosition = (success) => {
        window.finishGeolocation = success;
      };
    JS

    attach_file('word_chain_walk_step_image', Rails.root.join('spec/fixtures/files/480x320.png'), make_visible: true)

    within 'dialog[open]' do
      expect(page).to have_content('位置情報を確認しています')
      click_button 'キャンセル'
    end
    expect(page).to have_no_css('dialog[open]')

    page.execute_script <<~JS
      window.finishGeolocation({ coords: { latitude: 35.6586, longitude: 139.7454 } });
    JS

    expect(page).to have_field('word_chain_walk_step_latitude', with: '', type: 'hidden', visible: :all)
    expect(page).to have_field('word_chain_walk_step_longitude', with: '', type: 'hidden', visible: :all)
    expect(page).to have_button('写真とことばを記録する', disabled: true, visible: :all)
  end
end
