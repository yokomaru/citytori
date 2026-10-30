require 'rails_helper'

RSpec.describe 'WordChainWalkSteps', type: :system do
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

  scenario 'ステップ詳細画面からメモが編集できること' do
    log_in(user)

    visit word_chain_walk_word_chain_walk_step_path(word_chain_walk, word_chain_walk_step)
    click_link '編集', exact: true
    fill_in 'メモ', with: 'メモを更新した'

    click_button 'メモを更新する'

    expect(page).to have_content('メモを更新した')
    expect(page).to have_css('#flash_messages .notice-toast', text: 'メモを更新しました')
    expect(page).to have_current_path word_chain_walk_word_chain_walk_step_path(word_chain_walk, word_chain_walk_step)
  end

  scenario 'キャンセルを押したらステップ詳細画面からメモが編集されないこと' do
    log_in(user)

    visit word_chain_walk_word_chain_walk_step_path(word_chain_walk, word_chain_walk_step)
    click_link '編集', exact: true
    fill_in 'メモ', with: 'メモを更新した'

    click_link 'キャンセル'

    expect(page).to have_content('赤いりんご')
    expect(page).to have_current_path word_chain_walk_word_chain_walk_step_path(word_chain_walk, word_chain_walk_step)
  end
end
