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

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    expect(page).to have_css(
      'dialog[data-modal-target="modal"][open]'
    )

    fill_in '言葉', with: 'りんご'
    fill_in 'メモ', with: 'メモ'

    click_button '登録する'

    within '#word_chain_walk_steps' do
      expect(page).to have_content('りんご')
    end

    expect(page).to have_css(
      '#word_chain_walk_target',
      text: 'こ'
    )

    expect(page).to have_no_css(
      'dialog[data-modal-target="modal"][open]'
    )
  end

  scenario '登録失敗時、エラーの表示がモーダル内で確認できること' do
    log_in(user)

    visit word_chain_walk_path(word_chain_walk)

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    click_button '登録する'

    within 'dialog[data-modal-target="modal"][open]' do
      expect(page).to have_content("言葉を入力してください")
    end
  end

  scenario 'モーダルを閉じて再度開くと入力内容がリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    fill_in '言葉', with: 'りんご'
    fill_in 'メモ', with: 'メモ'

    click_button 'キャンセル'

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    within 'dialog[data-modal-target="modal"][open]' do
      expect(find_field('言葉').value).to be_blank
      expect(find_field('メモ').value).to be_blank
    end
  end

  scenario 'モーダルを閉じて再度開くとエラー表示がリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    click_button '登録する'

    within 'dialog[data-modal-target="modal"][open]' do
      expect(page).to have_css('#error_explanation')
    end

    click_button 'キャンセル'

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    within 'dialog[data-modal-target="modal"][open]' do
      expect(page).to have_no_css('#error_explanation')
    end
  end

  scenario 'モーダルを閉じると画像プレビューがリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    within 'dialog[data-modal-target="modal"][open]' do
      expect(
        find('[data-previews-target="image"]')[:src]
      ).to start_with('blob:')
    end

    click_button 'キャンセル'

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

  scenario 'モーダルを再度開くと位置情報を再取得する' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    begin
      set_browser_geolocation(35.6586, 139.7454)

      attach_file(
        'word_chain_walk_step_image',
        Rails.root.join('spec/fixtures/files/480x320.png'),
        make_visible: true
      )

      within 'dialog[data-modal-target="modal"][open]' do
        expect(page).to have_field('word_chain_walk_step_latitude', with: '35.6586', type: 'hidden')
        expect(page).to have_field('word_chain_walk_step_longitude', with: '139.7454', type: 'hidden')
        expect(page).to have_content('位置情報を取得しました。')
      end

      click_button 'キャンセル'

      set_browser_geolocation(34.6525, 135.5063)

      attach_file(
        'word_chain_walk_step_image',
        Rails.root.join('spec/fixtures/files/480x320.png'),
        make_visible: true
      )

      within 'dialog[data-modal-target="modal"][open]' do
        expect(page).to have_field('word_chain_walk_step_latitude', with: '34.6525', type: 'hidden')
        expect(page).to have_field('word_chain_walk_step_longitude', with: '135.5063', type: 'hidden')
        expect(page).to have_content('位置情報を取得しました。')
      end
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
