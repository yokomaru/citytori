require 'rails_helper'
require 'tempfile'

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

  def attach_step_image
    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )
  end

  def fill_in_step_form(word:, memo: '見つけた言葉のメモ')
    attach_step_image
    fill_in '見つけた言葉', with: word
    fill_in 'メモ', with: memo
  end

  scenario 'ログインユーザーがモーダルから画像付きStepを追加できること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    fill_in_step_form(word: 'りんご')

    expect do
      click_button '登録する'

      within '#word_chain_walk_steps' do
        expect(page).to have_content('りんご')
      end
    end.to change(WordChainWalkStep, :count).by(1)
  end

  scenario 'Stepを追加した後画面遷移せずにStep一覧と次の文字が更新されること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css('#word_chain_walk_steps')

    fill_in_step_form(word: 'りんご')

    expect do
      click_button '登録する'

      expect(page).to have_current_path(word_chain_walk_path(word_chain_walk))

      within '#word_chain_walk_steps' do
        expect(page).to have_content('りんご')
      end

      within '#word_chain_walk_target' do
        expect(page).to have_content('ご')
        expect(page).to have_content('に続く言葉を街の中から見つけましょう')
      end
    end.to change(WordChainWalkStep, :count).by(1)

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )
  end

  scenario '不正なwordを入力した場合、モーダル内にエラーが表示されること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_step_image
    fill_in '見つけた言葉', with: 'ごりら'
    click_button '登録する'

    within '[data-step-form-target="modal"]' do
      expect(page).to have_content('1件のエラーがあります')
      expect(page).to have_content('前の文字が繋がっていません')
    end
  end

  scenario '言葉を入力しないとStepを登録できず、モーダル内にエラーが表示されること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect do
      click_button '登録する'

      within '[data-step-form-target="modal"]' do
        expect(page).to have_content("Word can't be blank")
      end
    end.not_to change(WordChainWalkStep, :count)

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )
  end

  scenario 'キャンセルするとモーダルが閉じ、入力内容がリセットされること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_step_image
    fill_in '見つけた言葉', with: 'りんご'
    fill_in 'メモ', with: '赤いりんご'

    click_button 'キャンセル'

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )

    word_input = find('#word_chain_walk_step_word', visible: :all)
    memo_input = find('#word_chain_walk_step_memo', visible: :all)

    expect(word_input.value).to eq('')
    expect(memo_input.value).to eq('')
  end

  scenario '10MBを超える画像を選択するとモーダルを開かないこと' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    large_image = Tempfile.new([ 'large_image', '.png' ]).tap do |file|
      source_image = Rails.root.join('spec/fixtures/files/480x320.png')

      file.binmode
      file.write(File.binread(source_image))
      file.truncate(10.megabytes + 1)
      file.rewind
    end
    attach_file('word_chain_walk_step_image', large_image.path, make_visible: true)

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )

    expect(
      find('#word_chain_walk_step_image', visible: :all).value
    ).to be_empty
  ensure
    large_image&.close!
  end

  scenario '画像以外のファイルを選択するとモーダルを開かないこと' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)


    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/test_pdf.pdf'),
      make_visible: true
    )

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )

    expect(
      find('#word_chain_walk_step_image', visible: :all).value
    ).to be_empty
  end

  scenario 'モーダルを閉じて再度開くと、前回のエラー表示が消えること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    click_button '登録する'

    within '[data-step-form-target="modal"]' do
      expect(page).to have_content("Word can't be blank")
    end

    click_button 'キャンセル'

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    within '[data-step-form-target="modal"]' do
      expect(page).not_to have_content("Word can't be blank")
    end
  end

  scenario 'Stepを追加した後は最新Step削除ボタンは1つだけ表示されること' do
    word_chain_walk_step

    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_button('最新Stepを削除する', count: 1)

    fill_in_step_form(word: 'ごま')
    click_button '登録する'

    within '#word_chain_walk_steps' do
      expect(page).to have_content('ごま')
      expect(page).to have_content('りんご')
      expect(page).to have_button('最新Stepを削除する', count: 1)
    end
  end

  scenario '「ん」で終わる言葉を登録すると、散歩が完了すること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    fill_in_step_form(word: 'りん')

    expect do
      click_button '登録する'

      expect(page).to have_current_path(
        word_chain_walk_completion_path(word_chain_walk)
      )
    end.to change(WordChainWalkStep, :count).by(1)

    expect(word_chain_walk.reload.finished_at).to be_present
  end
end
