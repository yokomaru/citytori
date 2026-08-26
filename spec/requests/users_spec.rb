require "rails_helper"

RSpec.describe "Users", type: :request do
  def log_in(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: user.provider,
        uid: user.uid,
        info: {
          email: user.email,
          name: user.name
        }
      )

    get "/auth/google_oauth2/callback"
  end

  describe "DELETE /user" do
    it "退会をするとユーザーと紐づくデータが削除されること" do
      user = FactoryBot.create(:user)

      log_in(user)

      word_chain_walk = FactoryBot.create(:word_chain_walk, user: user)

      expect do
        expect do
          delete withdraw_user_path
        end.to change(User, :count).by(-1)
      end.to change(WordChainWalk, :count).by(-1)

      expect(response).to redirect_to(root_path)
      expect(User.exists?(user.id)).to be false
      expect(session[:user_id]).to be_nil
      expect(WordChainWalk.exists?(word_chain_walk.id)).to be false
    end
  end
end
