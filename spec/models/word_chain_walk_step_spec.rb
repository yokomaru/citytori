require 'rails_helper'

RSpec.describe WordChainWalkStep, type: :model do
  let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, start_char: 'り') }

  it 'has a valid factory' do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: 'りんご'
      )

    expect(word_chain_walk_step).to be_valid
  end

  it 'word_chain_walkがない場合は無効であること' do
    word_chain_walk_step =
      FactoryBot.build(:word_chain_walk_step, :with_image, word_chain_walk: nil)

    expect(word_chain_walk_step).to be_invalid
  end

  it 'WordChainWalkを削除した場合、紐づくStepも削除されること' do
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')
    expect { word_chain_walk.destroy }.to change(described_class, :count).by(-1)
  end

  it 'wordがなければ無効であること' do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, :with_image, word: nil)
    expect(word_chain_walk_step).to be_invalid
  end

  it 'wordが101文字以上の場合は無効であること' do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, :with_image, word: 'あ' * 101)
    expect(word_chain_walk_step).to be_invalid
  end

  it 'wordがひらがなと伸ばし棒のみの場合は有効であること' do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, :with_image, word: 'あいうえおー')
    expect(word_chain_walk_step).to be_valid
  end

  it 'wordにカタカナが含まれる場合は無効であること' do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, :with_image, word: 'アイウエオ')
    expect(word_chain_walk_step).to be_invalid
  end

  it '1件目のwordが散歩の開始文字から始まる場合は有効であること' do
    next_step = FactoryBot.build(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')
    expect(next_step).to be_valid
  end

  it '1件目のwordが散歩の開始文字から始まらない場合は無効であること' do
    next_step = FactoryBot.build(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'ごりら')
    expect(next_step).to be_invalid
  end

  it '2件目以降のwordが直前のwordの最後の文字から始まる場合は有効であること' do
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')
    second_step = FactoryBot.build(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'ごりら')
    expect(second_step).to be_valid
  end

  it '2件目以降のwordが直前のwordの最後の文字から始まらない場合は無効であること' do
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')
    second_step = FactoryBot.build(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'らっぱ')
    expect(second_step).to be_invalid
  end

  it 'しりとり散歩が終了済みなら新規ステップの追加はできない' do
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')
    word_chain_walk.update(finished_at: Time.zone.local(2026, 6, 6, 10, 0, 0))
    next_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: 'ごりら'
      )

    expect(next_step).to be_invalid
  end

  it '画像がない場合は無効であること' do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step)

    expect(word_chain_walk_step).to be_invalid
  end
end
