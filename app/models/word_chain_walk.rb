class WordChainWalk < ApplicationRecord
  ALLOW_START_CHARS = %w[
    あ い う え お か き く け こ さ し す せ そ
    た ち つ て と な に ぬ ね の は ひ ふ へ ほ
    ま み む め も や ゆ よ ら り る れ ろ わ
  ].freeze

  belongs_to :user
  has_many :word_chain_walk_steps, dependent: :destroy

  validates :start_char, presence: true
  validates :start_char, length: { is: 1 }
  validates :start_char, format: { with: /\A[#{ALLOW_START_CHARS.join}]\z/ }

  validates :started_at, presence: true
  validates :finished_at, comparison: { greater_than: :started_at }, allow_nil: true

  # 完了済みの散歩に対してfinished_atを再設定できないようにする
  validate :finished_at_cannot_change_once_set, on: :update
  validate :must_have_only_one_active_word_chain_walk

  after_initialize :assign_random_start_char, if: :new_record?
  after_initialize :assign_started_at, if: :new_record?

  scope :finished, -> { where.not(finished_at: nil) }
  scope :active, -> { where(finished_at: nil) }

  def finish
    return false if finished?

    update(finished_at: Time.current)
  end

  def finished?
    finished_at.present?
  end

  def latest_step
    word_chain_walk_steps.order(:id).last
  end

  def elapsed_seconds
    return nil if started_at.nil?

    if finished?
      finished_at - started_at
    else
      Time.zone.now - started_at
    end
  end

  def target_char
    return start_char if latest_step.nil?

    latest_step.normalize_last_char
  end

  def allowed_start_chars
    char = target_char
    WordChainWalkStep::NORMALIZED_HIRAGANA_CHARS.select { |k, v| v == char }.keys
  end

  private

  def assign_random_start_char
    return if start_char.present?

    self.start_char = ALLOW_START_CHARS.sample
  end

  def assign_started_at
    return if started_at.present?

    self.started_at = Time.zone.now
  end


  def finished_at_cannot_change_once_set
    return unless finished_at_changed? && finished_at_was.present?

    errors.add(:finished_at, "は既に設定されています")
  end

  def must_have_only_one_active_word_chain_walk
    return if user.nil?
    return if user.word_chain_walks.nil?
    return unless user.word_chain_walks.active.where.not(id: id).exists?

    errors.add(:base, "進行中の散歩があるため新しい散歩を作成できません")
  end
end
