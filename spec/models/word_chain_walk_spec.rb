require 'rails_helper'

RSpec.describe WordChainWalk, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:word_chain_walk)).to be_valid
  end

  it 'userがない場合は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, user: nil)

    expect(word_chain_walk).to be_invalid
  end

  it 'userを削除した場合、紐づくWordChainWalkも削除されること' do
    user = FactoryBot.create(:user)
    FactoryBot.create(:word_chain_walk, user: user)

    expect { user.destroy }.to change(described_class, :count).by(-1)
  end

  it 'start_charが空の時は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: nil)
    expect(word_chain_walk).to be_invalid
  end

  it 'start_charがひらがなで1文字場合は有効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'り')
    expect(word_chain_walk).to be_valid
  end

  it 'start_charがひらがなで1文字だが小文字の場合は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'ぁ')
    expect(word_chain_walk).to be_invalid
  end

  it 'start_charがひらがなで2文字の場合は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'あり')
    expect(word_chain_walk).to be_invalid
  end

  it 'start_charがひらがな以外で2文字以上場合は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'ABC')
    expect(word_chain_walk).to be_invalid
  end

  it 'started_atが空の時無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, started_at: nil)
    expect(word_chain_walk).to be_invalid
  end

  it 'finished_atが空の場合は有効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, finished_at: nil)
    expect(word_chain_walk).to be_valid
  end

  it 'finished_atがstarted_atより前の時は無効であること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, started_at: Time.zone.local(2026, 6, 2, 10, 0, 0),
                                                         finished_at: Time.zone.local(2026, 6, 1, 10, 0, 0))
    expect(word_chain_walk).to be_invalid
  end

  it 'ランダムなひらがな1文字が返ってくること' do
    word_chain_walk = described_class.new(started_at: Time.zone.local(2026, 6, 2, 10, 0, 0))

    expect(word_chain_walk.start_char).to match(/\A[あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわを]\z/)
  end

  it '終了日が埋まっていたら終了済みだと判定されること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, started_at: Time.zone.local(2026, 6, 2, 10, 0, 0),
                                                         finished_at: Time.zone.local(2026, 6, 3, 10, 0, 0))

    expect(word_chain_walk.finished?).to be true
  end

  it '終了日が空なら終了済みではないと判定されること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, finished_at: nil)

    expect(word_chain_walk.finished?).to be false
  end

  it '最新のステップが取得できること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'り')
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')
    new_step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'ごりら')

    expect(word_chain_walk.latest_step).to eq(new_step)
  end

  it 'ステップがない場合はnilが帰ってくること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'り')

    expect(word_chain_walk.latest_step).to be_nil
  end

  it 'ステップがある場合は、登録済みの最新ステップのwordの最後の1文字現在探している文字を取得できること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'り')
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: 'りんご')

    expect(word_chain_walk.target_char).to eq('ご')
  end

  it 'ステップがない場合は、start_charが現在探している文字として表示できること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, start_char: 'り')

    expect(word_chain_walk.target_char).to eq('り')
  end

  it 'まだ終了していない場合は現在時間から開始時間を引いた時間が帰ってくること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, started_at: Time.zone.local(2026, 6, 2, 10, 0, 0))
    travel_to Time.zone.local(2026, 6, 2, 11, 30, 0) do
      expect(word_chain_walk.elapsed_seconds).to eq 5400
    end
  end

  it '終了済み場合は終了時間から開始時間を引いた時間が帰ってくること' do
    word_chain_walk = FactoryBot.build(:word_chain_walk, started_at: Time.zone.local(2026, 6, 2, 10, 0, 0),
                                                         finished_at: Time.zone.local(2026, 6, 2, 11, 20, 21))
    expect(word_chain_walk.elapsed_seconds).to eq 4821
  end

  it 'activeはfinished_atがnilの散歩を返すこと' do
    active_walk = FactoryBot.create(:word_chain_walk, finished_at: nil)
    FactoryBot.create(
      :word_chain_walk,
      finished_at: Time.zone.local(2026, 6, 1, 11, 0, 0)
    )

    expect(described_class.active).to contain_exactly(active_walk)
  end

  it 'finishedはfinished_atがある散歩を返すこと' do
    FactoryBot.create(:word_chain_walk, finished_at: nil)
    finished_walk =
      FactoryBot.create(
        :word_chain_walk,
        finished_at: Time.zone.local(2026, 6, 1, 11, 0, 0)
      )

    expect(described_class.finished).to contain_exactly(finished_walk)
  end
end
