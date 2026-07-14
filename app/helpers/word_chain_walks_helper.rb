module WordChainWalksHelper
  def formatted_elapsed_time(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    seconds %= 60

    format("%d時間 %02d分 %02d秒", hours, minutes, seconds)
  end
end
