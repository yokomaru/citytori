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

  describe '.find_or_create_from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '12345',
        info: {
          email: 'test@example.com',
          name: 'テストユーザー'
        }
      )
    end

    it 'providerとuidが一致するUserがある場合は既存のUserを返すこと' do
      existing_user =
        FactoryBot.create(
          :user,
          provider: 'google_oauth2',
          uid: '12345',
          email: 'old@example.com',
          name: '既存ユーザー'
        )
      user = described_class.find_or_create_from_omniauth(auth)
      expect(user).to eq(existing_user)
    end

    it 'providerとuidが一致するUserがない場合は新しいUserを作成すること' do
      expect {
        described_class.find_or_create_from_omniauth(auth)
      }.to change(described_class, :count).by(1)
    end

    it 'auth情報がUserに保存されること' do
      user = described_class.find_or_create_from_omniauth(auth)
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('12345')
      expect(user.email).to eq('test@example.com')
      expect(user.name).to eq('テストユーザー')
    end
  end
end
