# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "12345",
      info: {
        email: "test@example.com",
        name: "テストユーザー"
      }
    )
  end

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    Rails.application.env_config["omniauth.auth"] = nil
  end

  describe "GET /auth/google_oauth2/callback" do
    it "Userを作成してログインする" do
      expect {
        get "/auth/google_oauth2/callback"
      }.to change(User, :count).by(1)

      user = User.find_by(provider: "google_oauth2", uid: "12345")

      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("ログインしました")
    end

    it "既存Userがいる場合はそのUserでログインする" do
      existing_user =
        FactoryBot.create(
          :user,
          provider: "google_oauth2",
          uid: "12345",
          email: "old@example.com",
          name: "既存ユーザー"
        )

      expect {
        get "/auth/google_oauth2/callback"
      }.not_to change(User, :count)

      expect(session[:user_id]).to eq(existing_user.id)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /auth/failure" do
    it "root_pathへリダイレクトする" do
      get "/auth/failure", params: { message: "invalid_credentials" }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Googleログインに失敗しました")
    end
  end

  describe "POST /logout" do
    it "ログアウトする" do
      get "/auth/google_oauth2/callback"

      expect(session[:user_id]).to be_present

      post "/logout"

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("ログアウトしました")
    end
  end
end
