require 'rails_helper'

RSpec.describe WordChainWalksHelper, type: :helper do
  it '与えられた秒数から時間と分と秒を返却すること' do
    expect(helper.formatted_elapsed_time(5400)).to eq('1時間 30分 00秒')
  end

  it '許容する文字が「」で区切られて表示されること' do
    user = FactoryBot.create(:user)
    word_chain_walk = FactoryBot.create(:word_chain_walk, user: user, start_char: "ほ")

    expect(helper.formatted_allowed_start_chars(word_chain_walk.allowed_start_chars)).to eq('「ぼ」「ぽ」')
  end
end
