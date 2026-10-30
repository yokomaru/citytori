require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "未ログインでもアクセスできる" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /how-to-play" do
    it "遊び方ページを表示する" do
      get how_to_play_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Citytoriの遊び方")
      expect(response.body).to include("ホームからGoogleアカウントでログインして、散歩を始められます。")
    end

    context "ログイン済みの場合" do
      let(:user) { FactoryBot.create(:user) }

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
          provider: user.provider, uid: user.uid,
          info: { email: user.email, name: user.name }
        )
        get "/auth/google_oauth2/callback"
      end

      it "自分の進行中の散歩があれば再開を案内する" do
        walk = FactoryBot.create(:word_chain_walk, user: user)
        get how_to_play_path
        expect(response.body).to include("進行中の散歩があります。続きから再開できます。")
        link = Nokogiri::HTML(response.body).at_css("a[href='#{word_chain_walk_path(walk)}'].landing-cta")
        expect(link.text).to eq("散歩を再開する")
        expect(response.body).not_to include("ホームから新しい散歩を始められます。")
      end

      it "散歩がなければ新しい散歩を案内する" do
        get how_to_play_path
        expect(response.body).to include("ホームから新しい散歩を始められます。")
        expect(response.body).to include("ホームに戻って始める")
      end

      it "初回ホームでは遊び方と上下の開始ボタンを表示する" do
        get root_path
        page = Nokogiri::HTML(response.body)
        expect(page.at_css(".home-how-to-play").text).to include("Citytoriの遊び方", "写真とことばを記録する")
        expect(page.css("button[data-action='walk-start#open']").size).to eq(2)
        expect(page.css("dialog[data-walk-start-target='modal']").size).to eq(1)
        expect(page.css("[data-controller='walk-start']").size).to eq(1)
        expect(response.body).not_to include("まだ散歩の記録はありません。")
      end

      it "進行中または完了した散歩があるホームでは初回の遊び方を表示しない" do
        walk = FactoryBot.create(:word_chain_walk, user: user)
        get root_path
        expect(response.body).not_to include('class="home-how-to-play"')

        walk.update!(finished_at: Time.current)
        get root_path
        expect(response.body).not_to include('class="home-how-to-play"')
        expect(response.body).to include("最近の散歩")
      end

      it "完了した散歩や他人の進行中の散歩では再開を案内しない" do
        FactoryBot.create(:word_chain_walk, user: user, finished_at: Time.current)
        FactoryBot.create(:word_chain_walk)
        get how_to_play_path
        expect(response.body).to include("ホームから新しい散歩を始められます。")
        expect(response.body).not_to include("進行中の散歩があります。")
      end
    end
  end
end
