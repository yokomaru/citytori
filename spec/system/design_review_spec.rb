require 'rails_helper'

RSpec.describe 'Design review improvements', type: :system do
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

  scenario '位置情報の応答待ちでも散歩を始められる' do
    page.execute_script('navigator.geolocation.getCurrentPosition = function() {}')
    first(:button, 'しりとり散歩をはじめる').click
    within 'dialog[open]' do
      expect(page).to have_content('位置情報を取得しています')
      click_button '待たずに散歩を始める'
    end
    expect(page).to have_content('しりとり散歩中')
    expect(user.word_chain_walks.count).to eq(1)
  end

  scenario 'メニューの開閉状態とEscape後のフォーカスが一致する' do
    button = find('button[aria-controls="header-menu"]')
    expect(button['aria-expanded']).to eq('false')
    button.click
    expect(button['aria-expanded']).to eq('true')
    expect(page).to have_link('遊び方')
    button.send_keys(:escape)
    expect(button['aria-expanded']).to eq('false')
    expect(page).to have_no_link('遊び方')
    expect(page.evaluate_script('document.activeElement.getAttribute("aria-controls")')).to eq('header-menu')
  end

  scenario '記録ダイアログをEscapeで閉じると撮影ボタンに戻り入力をリセットする' do
    walk = FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
    visit word_chain_walk_path(walk)
    attach_file('word_chain_walk_step_image', Rails.root.join('spec/fixtures/files/480x320.png'), make_visible: true)
    within 'dialog[open]' do
      expect(page).to have_css('h2', text: '写真とことばを記録する')
      fill_in '見つけたことば', with: 'りんご'
      find('#word_chain_walk_step_word').send_keys(:escape)
    end
    expect(page).to have_no_css('dialog[open]')
    expect(page.evaluate_script('document.activeElement.textContent.trim()')).to eq('写真を撮る')
    expect(find('#word_chain_walk_step_word', visible: :all).value).to eq('')
  end

  scenario '狭い画面でも長時間の散歩カードの再開導線がカード内に収まる' do
    FactoryBot.create(:word_chain_walk, user: user, start_char: 'り', started_at: 5.days.ago)
    [ 320, 375, 390, 420, 640, 1280 ].each do |width|
      page.current_window.resize_to(width, 900)
      visit word_chain_walks_path
      expect(page).to have_content('続きから歩く')
      fits = page.evaluate_script(<<~JS)
        [...document.querySelectorAll('.walk-index-card')].every(card => {
          const outer = card.getBoundingClientRect();
          return [...card.querySelectorAll('.walk-index-card-content, .walk-index-resume')].every(child => {
            const inner = child.getBoundingClientRect();
            return inner.bottom <= outer.bottom && inner.right <= outer.right;
          });
        }) && document.documentElement.scrollWidth <= window.innerWidth
      JS
      expect(fits).to be(true), "card content must remain visible at #{width}px"
    end
  end

  scenario '同じ地点の記録も名前付きのリンクから選択できる' do
    walk = FactoryBot.create(:word_chain_walk, user: user, start_char: 'き')
    first = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: walk, word: 'き', latitude: 35.68, longitude: 139.76)
    last = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: walk, word: 'きく', latitude: 35.68, longitude: 139.76)
    walk.finish
    visit map_word_chain_walk_path(walk)
    expect(page).to have_css('a[aria-label="1. きの記録を見る"]')
    expect(page).to have_css('a[aria-label="2. きくの記録を見る"]')
    within 'nav[aria-label="場所のある記録"]' do
      click_link '1. き', exact: true
    end
    within '#selected_walk_step' do
      expect(page).to have_link('き', href: word_chain_walk_word_chain_walk_step_path(walk, first, from: "map"))
    end
    within 'nav[aria-label="場所のある記録"]' do
      click_link '2. きく', exact: true
    end
    within '#selected_walk_step' do
      expect(page).to have_link('きく', href: word_chain_walk_word_chain_walk_step_path(walk, last, from: "map"))
    end
    expect(page).to have_css('#selected_walk_step:focus')
  end
end
