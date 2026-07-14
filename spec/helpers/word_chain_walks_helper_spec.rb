require 'rails_helper'

RSpec.describe WordChainWalksHelper, type: :helper do
  it '与えられた秒数から時間と分と秒を返却すること' do
    expect(helper.formatted_elapsed_time(5400)).to eq('1時間 30分 00秒')
  end
end
