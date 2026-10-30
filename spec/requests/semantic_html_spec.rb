require "rails_helper"

RSpec.describe "Semantic page structure", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider, uid: user.uid,
      info: { email: user.email, name: user.name }
    )
    get "/auth/google_oauth2/callback"
  end

  def document
    Nokogiri::HTML(response.body)
  end

  def expect_page_landmarks
    expect(response).to have_http_status(:ok)
    expect(document.css("main").size).to eq(1)
    expect(document.css("main h1").size).to eq(1)
    ids = document.css("[id]").map { |node| node["id"] }
    expect(ids.uniq).to eq(ids)
  end

  it "uses one main landmark and a nested heading hierarchy on the first home" do
    get root_path
    expect_page_landmarks
    expect(document.at_css(".home-how-to-play h2").text).to eq("Citytoriの遊び方")
    expect(document.css(".how-to-step h3").size).to eq(3)
    expect(document.at_css("#location-information-heading").name).to eq("h3")

    get how_to_play_path
    expect_page_landmarks
    expect(document.css(".how-to-step h2").size).to eq(3)
  end

  it "exposes walk cards as a list of titled articles with dates" do
    FactoryBot.create(:word_chain_walk, user: user, finished_at: Time.current)
    get word_chain_walks_path
    expect_page_landmarks
    expect(document.css("ul.walk-index-list > li > article h3 time[datetime]").size).to eq(1)

    get root_path
    expect_page_landmarks
    expect(document.css("ul.home-recent-grid > li > article h3 time[datetime]").size).to eq(1)
  end

  it "keeps records ordered and deletion a confirmed form action on both tabs" do
    walk = FactoryBot.create(:word_chain_walk, user: user)
    step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: walk,
                             latitude: 35.68, longitude: 139.76)
    get word_chain_walk_path(walk)
    expect_page_landmarks
    expect(document.at_css(".active-walk-latest-body h3").text.strip).to eq(step.word)
    walk.update!(finished_at: Time.current)

    get word_chain_walk_path(walk)
    expect_page_landmarks
    expect(document.css("#word_chain_walk_steps ol > li h2").map(&:text).map(&:strip)).to eq([ step.word ])
    expect(document.at_css(".walk-record-card time")["datetime"]).to eq(step.created_at.iso8601)

    [ word_chain_walk_path(walk), map_word_chain_walk_path(walk) ].each do |path|
      get path
      form = document.at_css("form[action='#{word_chain_walk_path(walk)}']")
      expect(form["method"]).to eq("post")
      expect(form.at_css("input[name='_method']")["value"]).to eq("delete")
      expect(form.at_css("button.walk-delete-button")["data-turbo-confirm"]).to eq("この散歩を削除しますか？")
    end

    get word_chain_walk_word_chain_walk_step_path(walk, step), headers: { "Turbo-Frame" => "selected_walk_step" }
    expect(document.css("turbo-frame#selected_walk_step h2").size).to eq(1)
  end
end
