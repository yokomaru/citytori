class WordChainWalk < ApplicationRecord
  ALLOW_START_CHARS = %w[
    あ い う え お か き く け こ さ し す せ そ
    た ち つ て と な に ぬ ね の は ひ ふ へ ほ
    ま み む め も や ゆ よ ら り る れ ろ わ
  ].freeze

  belongs_to :user

  validates :start_char, presence: true
  validates :start_char, length: { is: 1 }
  validates :start_char, format: { with: /\A[#{ALLOW_START_CHARS.join}]\z/ }

  validates :started_at, presence: true
  validates :finished_at, comparison: { greater_than: :started_at }, allow_nil: true

  after_initialize :assign_random_start_char, if: :new_record?
  after_initialize :assign_started_at, if: :new_record?
end
