require 'rails_helper'

RSpec.describe 'WordChainWalks', type: :system do
  before do
    driven_by(:rack_test)
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

  scenario 'ログインユーザーが散歩を開始して画像付きStepを追加できること' do
    user = FactoryBot.create(:user)

    log_in(user)

    visit word_chain_walks_path

    expect do
      click_button '始める'
    end.to change(WordChainWalk, :count).by(1)

    expect(page).to have_content('しりとり散歩を開始しました')
    word_chain_walk = WordChainWalk.order(:id).last
    word = "#{word_chain_walk.start_char}す"
    click_link '写真を撮る'
    expect(page).to have_content("#{word_chain_walk.target_char} を探しましょう")
    fill_in '見つけた言葉', with: word
    fill_in 'メモ', with: '見つけた言葉のメモ'
    attach_file '写真', Rails.root.join('spec/fixtures/files/480x320.png')
    expect do
      click_button '登録する'
    end.to change(WordChainWalkStep, :count).by(1)
    expect(page).to have_content('ステップを追加しました')
    expect(page).to have_content(word)
    expect(page).to have_content('見つけた言葉のメモ')
    click_link word
    expect(page).to have_content('Step詳細')
    expect(page).to have_content(word)
    expect(page).to have_content('見つけた言葉のメモ')
  end

  scenario '不正なwordを入力した場合、エラーが表示されること' do
    user = FactoryBot.create(:user)
    word_chain_walk = FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
    log_in(user)
    visit new_word_chain_walk_word_chain_walk_step_path(word_chain_walk)
    fill_in '見つけた言葉', with: 'ごりら'
    attach_file '写真', Rails.root.join('spec/fixtures/files/480x320.png')
    click_button '登録する'
    expect(page).to have_content('1件のエラーがあります')
    expect(page).to have_content('前の文字が繋がっていません')
  end

  scenario '画像がない場合、エラーが表示されること' do
    user = FactoryBot.create(:user)
    word_chain_walk = FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
    log_in(user)
    visit new_word_chain_walk_word_chain_walk_step_path(word_chain_walk)
    fill_in '見つけた言葉', with: 'りんご'
    click_button '登録する'
    expect(page).to have_content('1件のエラーがあります')
    expect(page).to have_content('Image を添付してください')
  end
end
