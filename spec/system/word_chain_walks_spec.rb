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

  scenario '登録失敗時、エラーの表示がモーダル内で確認できること' do
    log_in(user)

    visit word_chain_walk_path(word_chain_walk)
    click_button '写真を撮る'

    attach_file(
      '写真',
      Rails.root.join('spec/fixtures/files/480x320.png')
    )

    click_button '登録する'

    within 'dialog[data-modal-target="modal"][open]' do
      expect(page).to have_content("Word can't be blank")
    end
  end

  scenario 'モーダルを閉じて再度開くと入力内容がリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    click_button '写真を撮る'
    fill_in '見つけた言葉', with: 'りんご'
    fill_in 'メモ', with: 'メモ'

    click_button 'キャンセル'
    click_button '写真を撮る'

    within 'dialog[data-modal-target="modal"][open]' do
      expect(find_field('見つけた言葉').value).to be_blank
      expect(find_field('メモ').value).to be_blank
    end
  end

  scenario 'モーダルを閉じて再度開くとエラー表示がリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    click_button '写真を撮る'
    click_button '登録する'

    within 'dialog[data-modal-target="modal"][open]' do
      expect(page).to have_css('#error_explanation')
    end

    click_button 'キャンセル'
    click_button '写真を撮る'

    within 'dialog[data-modal-target="modal"][open]' do
      expect(page).to have_no_css('#error_explanation')
    end
  end

  scenario 'モーダルを閉じて再度開くと画像プレビューがリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    click_button '写真を撮る'

    attach_file('写真', Rails.root.join('spec/fixtures/files/480x320.png'))

    expect(page).to have_css(
      '[data-previews-target="preview"]:not(.hidden)'
    )

    expect(
      find('[data-previews-target="image"]')[:src]
    ).to start_with('blob:')

    click_button 'キャンセル'
    click_button '写真を撮る'

    within 'dialog[data-modal-target="modal"][open]' do
      expect(
        find('[data-previews-target="input"]', visible: :all).value
      ).to be_blank

      expect(page).to have_css(
        '[data-previews-target="preview"].hidden',
        visible: :all
      )

      expect(
        find('[data-previews-target="image"]', visible: :all)[:src]
      ).to be_blank
    end
  end

  scenario 'モーダルを閉じると位置情報がリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    begin
      page.driver.browser.execute_cdp(
        'Emulation.setGeolocationOverride',
        latitude:  35.6586,
        longitude: 139.7454,
        accuracy: 100
      )

      click_button '写真を撮る'
      click_button '位置情報を取得する'

      within 'dialog[data-modal-target="modal"][open]' do
        expect(find('#word_chain_walk_step_latitude', visible: :all).value).to eq('35.6586')
        expect(find('#word_chain_walk_step_longitude', visible: :all).value).to eq('139.7454')
        expect(page).to have_content('位置情報を取得しました。')
        expect(page).to have_content('緯度: 35.6586, 経度: 139.7454')
      end

      click_button 'キャンセル'
      click_button '写真を撮る'

      within 'dialog[data-modal-target="modal"][open]' do
        expect(find('#word_chain_walk_step_latitude', visible: :all).value).to be_blank
        expect(find('#word_chain_walk_step_longitude', visible: :all).value).to be_blank
        expect(page).to have_no_content('位置情報を取得しました。')
        expect(page).to have_no_content('緯度:')
      end
    ensure
      page.driver.browser.execute_cdp('Emulation.clearGeolocationOverride')
    end
  end
end
