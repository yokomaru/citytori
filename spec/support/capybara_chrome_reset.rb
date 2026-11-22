# Chromeのバージョン158からCapybara3.40.0のreset!が送るStorage.clearDataForOriginのorigin:"*"が受け付けられなくなったため、"*"を使わない命令に置き換える
# Capybaraが直った版を出したらモジュールごと消す。
# https://github.com/teamcapybara/capybara/issues/2865
module ChromeResetWithoutWildcardOrigin
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")
    if params[:storageTypes].include?("local_storage")
      super(cmd, { origin: Capybara.current_session.server.base_url, storageTypes: "local_storage" })
    end
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetWithoutWildcardOrigin)
