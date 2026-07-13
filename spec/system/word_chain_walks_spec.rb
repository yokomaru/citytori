require 'rails_helper'

RSpec.describe 'WordChainWalks', type: :system do
  before do
    driven_by(:rack_test)
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
    attach_file '写真', Rails.root.join('spec/fixtures/files/480x320.png')
  end

  def fill_in_step_form(word:, memo: '見つけた言葉のメモ')
    fill_in '見つけた言葉', with: word
    fill_in 'メモ', with: memo
    attach_step_image
  end

  scenario 'ログインユーザーが散歩を開始できること' do
    log_in(user)
    visit word_chain_walks_path

    expect do
      click_button '始める'
    end.to change(WordChainWalk, :count).by(1)
  end

  scenario '散歩開始後に完了メッセージが表示されること' do
    log_in(user)
    visit word_chain_walks_path

    click_button '始める'

    expect(page).to have_content('しりとり散歩を開始しました')
  end

  scenario 'ログインユーザーが画像付きStepを追加できること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    click_link '写真を撮る'
    fill_in_step_form(word: 'りんご')

    expect do
      click_button '登録する'
    end.to change(WordChainWalkStep, :count).by(1)
  end

  scenario 'Step追加後に完了メッセージが表示されること' do
    log_in(user)
    visit new_word_chain_walk_word_chain_walk_step_path(word_chain_walk)

    fill_in_step_form(word: 'りんご')
    click_button '登録する'

    expect(page).to have_content('ステップを追加しました')
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
    visit new_word_chain_walk_word_chain_walk_step_path(word_chain_walk)
    fill_in '見つけた言葉', with: 'ごりら'
    attach_step_image
    click_button '登録する'
    expect(page).to have_content('1件のエラーがあります')
    expect(page).to have_content('前の文字が繋がっていません')
  end

  scenario '画像がない場合、エラーが表示されること' do
    log_in(user)
    visit new_word_chain_walk_word_chain_walk_step_path(word_chain_walk)
    fill_in '見つけた言葉', with: 'りんご'
    click_button '登録する'
    expect(page).to have_content('1件のエラーがあります')
    expect(page).to have_content('Image を添付してください')
  end

  scenario '進行中の散歩を完了できること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)
    expect(page).to have_button('散歩を完了する')
    expect do
      click_button '散歩を完了する'
    end.to change { word_chain_walk.reload.finished? }.from(false).to(true)
    expect(page).to have_content('しりとり散歩が完了しました')
  end
end
