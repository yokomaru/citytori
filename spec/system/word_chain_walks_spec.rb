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

  scenario 'ログインユーザーが散歩を開始できること' do
    log_in(user)
    visit word_chain_walks_path

    expect(page).to have_button('始める')

    expect do
      click_button '始める'
      expect(page).to have_content('しりとり散歩を開始しました')
    end.to change(WordChainWalk, :count).by(1)
  end

  scenario '散歩開始後に開始メッセージが表示されること' do
    log_in(user)
    visit word_chain_walks_path

    click_button '始める'

    expect(page).to have_content('しりとり散歩を開始しました')
  end

  scenario 'ログインユーザーが画像付きStepを追加できること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    fill_in_step_form(word: 'りんご')
    expect(page).to have_button('登録する')

    expect do
      click_button '登録する'
      within '#word_chain_walk_steps' do
        expect(page).to have_content('りんご')
      end
    end.to change(WordChainWalkStep, :count).by(1)
  end

  scenario 'Step追加後に完了メッセージが表示されること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    fill_in_step_form(word: 'りんご')
    expect(page).to have_button('登録する')

    expect do
      click_button '登録する'
      expect(page).to have_content('言葉を登録しました')
    end.to change(WordChainWalkStep, :count).by(1)
  end

  scenario '追加したStepが散歩詳細画面に表示されること' do
    step = word_chain_walk_step

    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_content(step.word)
    expect(page).to have_content(step.memo)
  end

  scenario 'Step詳細画面を表示できること' do
    step = word_chain_walk_step

    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    click_link step.word

    expect(page).to have_content('Step詳細')
  end

  scenario 'Step詳細画面にwordとmemoが表示されること' do
    log_in(user)

    visit word_chain_walk_word_chain_walk_step_path(
      word_chain_walk,
      word_chain_walk_step
    )

    expect(page).to have_content(word_chain_walk_step.word)
    expect(page).to have_content(word_chain_walk_step.memo)
  end

  scenario '不正なwordを入力した場合、エラーが表示されること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_step_image
    fill_in '見つけた言葉', with: 'ごりら'
    click_button '登録する'

    expect(page).to have_content('1件のエラーがあります')
    expect(page).to have_content('前の文字が繋がっていません')
  end

  scenario '進行中の散歩を完了できること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_button('散歩を完了する')

    accept_confirm '散歩を完了しますか？' do
      click_button '散歩を完了する'
    end

    expect(page).to have_current_path(
      word_chain_walk_completion_path(word_chain_walk)
    )

    expect(page).to have_content('しりとり散歩が完了しました')
    expect(word_chain_walk.reload).to be_finished
  end

  scenario '画面遷移せずにStep一覧と次の文字が更新されること' do
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

  scenario '「ん」で終わる言葉を登録すると、散歩が完了する' do
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

  scenario '言葉を入力しないとStepを登録できず、モーダル内にエラーが表示される' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    expect do
      click_button '登録する'

      expect(page).to have_content("Word can't be blank")
    end.not_to change(WordChainWalkStep, :count)

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )
  end

  scenario 'Stepが0件の散歩でも、最初の1件を一覧に追加できる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css('#word_chain_walk_steps')
    expect(page).not_to have_content('りんご')

    fill_in_step_form(word: 'りんご')

    expect do
      click_button '登録する'

      within '#word_chain_walk_steps' do
        expect(page).to have_content('りんご')
      end
    end.to change(WordChainWalkStep, :count).by(1)
  end

  scenario 'キャンセルするとモーダルが閉じ、入力内容がリセットされる' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    attach_step_image

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: true
    )

    fill_in '見つけた言葉', with: 'りんご'

    click_button 'キャンセル'

    expect(page).to have_css(
      '[data-step-form-target="modal"]',
      visible: false
    )

    word_input = find('#word_chain_walk_step_word', visible: :all)

    expect(word_input.value).to eq('')
  end

  scenario '10MBを超える画像を選択するとモーダルを開かない' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    large_image = Tempfile.new([ 'large_image', '.png' ]).tap do |file|
      source_image = Rails.root.join('spec/fixtures/files/480x320.png')

      file.binmode
      file.write(File.binread(source_image))
      file.truncate(10.megabytes + 1)
      file.rewind
    end

    page.execute_script('window.alert = function(msg) { window._alertMsg = msg; }')

    attach_file('word_chain_walk_step_image', large_image.path, make_visible: true)

    expect(page.evaluate_script('window._alertMsg')).to eq(
      '画像は10MB以下にしてください。'
    )

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

  scenario 'モーダルを閉じて再度開くと、前回のエラー表示が消える' do
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

  scenario '最新Step削除ボタンは1つだけ表示されること' do
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
end
