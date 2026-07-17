class WordChainWalkStep < ApplicationRecord
  belongs_to :word_chain_walk

  has_one_attached :image

  validates :word, presence: true
  validates :word, length: { maximum: 100 }
  validates :word, format: { with: /\A[ぁ-んー]*\z/ }
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90, allow_nil: true }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180, allow_nil: true }

  validate :image_attached
  validate :image_size_within_limit
  validate :must_connect_previous_char
  validate :word_chain_walk_must_not_be_finished
  validate :latitude_and_longitude_must_be_both_present_or_blank

  private

  def image_attached
    errors.add(:image, "を添付してください") unless image.attached?
  end

  def image_size_within_limit
    return unless image.attached?
    return if image.blob.byte_size <= 10.megabytes

    errors.add(:image, "は10MB以下にしてください")
  end

  def must_connect_previous_char
    return if word.blank?
    return if word_chain_walk.blank?

    return if word_chain_walk.target_char == word[0] # TODO: 本当はword[0]を正規化する必要がある

    errors.add(:word, "と前の文字が繋がっていません")
  end

  def word_chain_walk_must_not_be_finished
    return if word_chain_walk.blank?
    return unless word_chain_walk.finished?

    errors.add(:base, "終了済みの散歩にはステップを追加できません")
  end

  def latitude_and_longitude_must_be_both_present_or_blank
    return if latitude.blank? && longitude.blank?
    return if latitude.present? && longitude.present?

    errors.add(:base, "緯度と経度は両方入力してください")
  end
end
