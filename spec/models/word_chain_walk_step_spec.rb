require 'rails_helper'

RSpec.describe WordChainWalkStep, type: :model do
  let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, start_char: 'り') }
  let(:finished_word_chain_walk) do
    FactoryBot.create(
      :word_chain_walk,
      start_char: 'り',
      finished_at: Time.current
    )
  end

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

  it 'wordの先頭が伸ばし棒の場合は無効であること' do
    word_chain_walk_step = FactoryBot.build(:word_chain_walk_step, :with_image, word: 'ーあいうえお')
    expect(word_chain_walk_step).to be_invalid
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

  it '紐づく散歩が完了済みの場合はStepを追加できないこと' do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: finished_word_chain_walk,
        word: 'りんご'
      )

    expect(word_chain_walk_step).to be_invalid
    expect(word_chain_walk_step.errors[:base]).to include(
      '終了済みの散歩にはステップを追加できません'
    )
  end

  it "正常な緯度と経度の場合は有効であること" do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: "りんご",
        latitude: 35.681236,
        longitude: 139.767125
      )

    expect(word_chain_walk_step).to be_valid
  end

  it "緯度が範囲外の場合は無効であること" do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: "りんご",
        latitude: 91,
        longitude: 139.767125
      )

    expect(word_chain_walk_step).to be_invalid
  end

  it "経度が範囲外の場合は無効であること" do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: "りんご",
        latitude: 35.681236,
        longitude: 181
      )

    expect(word_chain_walk_step).to be_invalid
  end

  it "緯度と経度が両方nilの場合は有効であること" do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: "りんご",
        latitude: nil,
        longitude: nil
      )

    expect(word_chain_walk_step).to be_valid
  end

  it "緯度だけある場合は無効であること" do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: "りんご",
        latitude: 35.681236,
        longitude: nil
      )

    expect(word_chain_walk_step).to be_invalid
  end

  it "経度だけある場合は無効であること" do
    word_chain_walk_step =
      FactoryBot.build(
        :word_chain_walk_step,
        :with_image,
        word_chain_walk: word_chain_walk,
        word: "りんご",
        latitude: nil,
        longitude: 139.767125
      )

    expect(word_chain_walk_step).to be_invalid
  end

  it '10MBの画像は有効である' do
    step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: 'りんご')

    step.image = fixture_file_upload("spec/fixtures/files/10MB.png")

    expect(step).to be_valid
  end

  it '10MB以上のサイズの画像は無効である' do
    step = FactoryBot.build(:word_chain_walk_step, word_chain_walk: word_chain_walk, word: 'りんご')

    step.image = fixture_file_upload("spec/fixtures/files/11MB.png")

    expect(step).to be_invalid
    expect(step.errors[:image]).to include("は10MB以下にしてください")
  end

  it "PNGファイルは有効であること" do
    step = FactoryBot.build(
        :word_chain_walk_step,
        word_chain_walk: word_chain_walk,
        word: "りんご"
      )

    step.image = fixture_file_upload("spec/fixtures/files/480x320.png")

    expect(step).to be_valid
  end

  it "JPEGファイルは有効であること" do
    step = FactoryBot.build(:word_chain_walk_step)

    step.image = fixture_file_upload("spec/fixtures/files/test_jpeg.jpeg")

    expect(step).to be_valid
  end

  it "PNG、JPEG以外のファイルは無効であること" do
    step = FactoryBot.build(:word_chain_walk_step)

    step.image = fixture_file_upload("spec/fixtures/files/test_pdf.pdf")

    expect(step).to be_invalid
    expect(step.errors[:image]).to include("はPNGまたはJPEG形式の画像にしてください")
  end

  describe "#normalize_first_char" do
    it "通常のひらがなはそのまま先頭の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "いるか"
      # debugger
      expect(step.normalize_first_char).to eq("い")
    end

    it "濁音は静音に変換してから先頭の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "がくせい"

      expect(step.normalize_first_char).to eq("か")
    end

    it "半濁音は清音に変換から先頭の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "ぱん"

      expect(step.normalize_first_char).to eq("は")
    end

    it "小文字は通常文字に変換から先頭の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "ゃさい"

      expect(step.normalize_first_char).to eq("や")
    end
  end

  describe "#normalize_last_char" do
    it "通常のひらがなはそのまま末尾の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "いるか"

      expect(step.normalize_last_char).to eq("か")
    end

    it "濁音は静音に変換してから末尾の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "りんご"

      expect(step.normalize_last_char).to eq("こ")
    end

    it "小文字は通常文字に変換から末尾の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "きゃ"

      expect(step.normalize_last_char).to eq("や")
    end

    it "末尾の伸ばし棒がある場合は伸ばし棒を除去した末尾の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "こーひー"

      expect(step.normalize_last_char).to eq("ひ")
    end

    it "末尾の伸ばし棒が複数ある場合も伸ばし棒を除去した末尾の文字を返すこと" do
      step = FactoryBot.build(:word_chain_walk_step)

      step.word = "こーひーー"

      expect(step.normalize_last_char).to eq("ひ")
    end
  end
end
