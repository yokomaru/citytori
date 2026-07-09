class User < ApplicationRecord
  validates :provider, presence: true, uniqueness: { scope: :uid }
  validates :uid, presence: true
  validates :email, presence: true
  validates :name, presence: true

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by!(
      provider: auth.provider,
      uid: auth.uid
    ) do |user|
      user.email = auth.info.email
      user.name = auth.info.name
    end
  end
end
