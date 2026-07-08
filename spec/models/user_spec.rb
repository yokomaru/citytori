require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:user)).to be_valid
  end

  it 'providerがなければ無効であること' do
    user = FactoryBot.build(:user, provider: nil)
    expect(user).to be_invalid
  end

  it 'uidがなければ無効であること' do
    user = FactoryBot.build(:user, uid: nil)
    expect(user).to be_invalid
  end

  it 'emailがなければ無効であること' do
    user = FactoryBot.build(:user, email: nil)
    expect(user).to be_invalid
  end

  it 'nameがなければ無効であること' do
    user = FactoryBot.build(:user, name: nil)
    expect(user).to be_invalid
  end

  it '同じproviderとuidの組み合わせは無効であること' do
    FactoryBot.create(:user, provider: 'google_oauth2', uid: '12345')
    user = FactoryBot.build(:user, provider: 'google_oauth2', uid: '12345')
    expect(user).to be_invalid
  end
end
