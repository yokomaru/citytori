class WordChainWalkStep < ApplicationRecord
  belongs_to :word_chain_walk

  has_one_attached :image

  validates :word, presence: true
  validates :word, length: { maximum: 100 }
  validates :word, format: { with: /\A[ぁ-んー]*\z/ }
  validate :image_attached

  private
  def image_attached
    errors.add(:image, "を添付してください") unless image.attached?
  end
end
