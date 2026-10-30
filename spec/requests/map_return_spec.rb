require "rails_helper"

RSpec.describe "Map return navigation", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:walk) { FactoryBot.create(:word_chain_walk, user: user) }
  let!(:step) do
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: walk,
                      latitude: 35.68, longitude: 139.76)
  end

  before do
    walk.update!(finished_at: Time.current)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider, uid: user.uid,
      info: { email: user.email, name: user.name }
    )
    get "/auth/google_oauth2/callback"
  end

  def back_href
    Nokogiri::HTML(response.body).at_css(".walk-step-detail-back a")["href"]
  end

  it "returns map-origin details to the same selected record" do
    get word_chain_walk_word_chain_walk_step_path(walk, step), params: { from: "map" }
    expect(back_href).to eq(map_word_chain_walk_path(walk, selected_step: step.id))
    get back_href
    page = Nokogiri::HTML(response.body)
    expect(page.at_css("[data-walk-map-selected-id-value]")["data-walk-map-selected-id-value"]).to eq(step.id.to_s)
    expect(page.at_css("#selected_walk_step h2").text.strip).to eq(step.word)
    expect(page.at_css("#selected_walk_step a")["href"]).to eq(word_chain_walk_word_chain_walk_step_path(walk, step, from: "map"))
  end

  it "keeps the usual return destination for non-map visits and invalid origins" do
    [ nil, "https://example.com" ].each do |origin|
      get word_chain_walk_word_chain_walk_step_path(walk, step), params: { from: origin }
      expect(back_href).to eq(word_chain_walk_path(walk))
    end
  end

  it "does not display another walk's record or an invalid selection" do
    other = FactoryBot.create(:word_chain_walk_step, :with_image)
    [ other.id.to_s, "missing" ].each do |id|
      get map_word_chain_walk_path(walk), params: { selected_step: id }
      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).css("#selected_walk_step .walk-record-card")).to be_empty
    end
  end

  it "does not return to a map for an unfinished walk" do
    active_walk = FactoryBot.create(:word_chain_walk, user: user)
    active_step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: active_walk)
    get word_chain_walk_word_chain_walk_step_path(active_walk, active_step), params: { from: "map" }
    expect(back_href).to eq(word_chain_walk_path(active_walk))
  end
end
