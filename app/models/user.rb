class User < ApplicationRecord
  validates :provider, presence: true, uniqueness: { scope: :uid }
  validates :uid, presence: true
  validates :email, presence: true
  validates :name, presence: true
end
