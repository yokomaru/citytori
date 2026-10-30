module WordChainWalksHelper
  def formatted_elapsed_time(seconds)
    minutes = [ seconds.to_i, 0 ].max / 60
    return "1分未満" if minutes.zero?

    hours, remaining_minutes = minutes.divmod(60)
    return "#{minutes}分" if hours.zero?

    [ "#{hours}時間", ("#{remaining_minutes}分" if remaining_minutes.positive?) ].compact.join(" ")
  end

  def formatted_allowed_start_chars(chars)
    chars.map { |char| "「#{char}」" }.join
  end
end
