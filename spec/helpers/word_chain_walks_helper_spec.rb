require 'rails_helper'

RSpec.describe WordChainWalksHelper, type: :helper do
  it '所要時間を分単位で読みやすく表示すること' do
    expect(helper.formatted_elapsed_time(5400)).to eq('1時間 30分')
  end

  it '1分未満、分のみ、時間のみ、日をまたぐ時間を表示すること' do
    { 0 => "1分未満", 59 => "1分未満", 60 => "1分", 1500 => "25分", 3600 => "1時間", 90000 => "25時間" }.each do |seconds, label|
      expect(helper.formatted_elapsed_time(seconds)).to eq(label)
    end
  end

  it '許容する文字が「」で区切られて表示されること' do
    user = FactoryBot.create(:user)
    word_chain_walk = FactoryBot.create(:word_chain_walk, user: user, start_char: "ほ")

    expect(helper.formatted_allowed_start_chars(word_chain_walk.allowed_start_chars)).to eq('「ぼ」「ぽ」')
  end
end
