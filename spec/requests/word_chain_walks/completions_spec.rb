require 'rails_helper'

RSpec.describe 'WordChainWalks::Completions', type: :request do
  let(:user) { FactoryBot.create(:user) }

  let(:word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
  end

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

    get '/auth/google_oauth2/callback'
  end

  describe 'PATCH /word_chain_walks/:word_chain_walk_id/completion' do
    it '進行中の散歩を完了した後に完了画面へリダイレクトすること' do
      log_in(user)

      expect do
        patch word_chain_walk_completion_path(word_chain_walk),
                params: { word_chain_walk: { finish_latitude: 35.681236, finish_longitude: 139.767125 } }
      end.to change { word_chain_walk.reload.finished? }.from(false).to(true)
      expect(word_chain_walk.finished_at).to be_present
      expect(response).to redirect_to(word_chain_walk_completion_path(word_chain_walk))
    end

    it '他人の散歩は完了できず404エラーになること' do
      log_in(user)

      other_user = FactoryBot.create(:user)
      other_word_chain_walk = FactoryBot.create(:word_chain_walk, user: other_user, start_char: 'り')

      expect do
        patch word_chain_walk_completion_path(other_word_chain_walk),
                params: { word_chain_walk: { finish_latitude: 35.681236, finish_longitude: 139.767125 } }
      end.not_to change { other_word_chain_walk.reload.finished_at }

      expect(response).to have_http_status(:not_found)
    end

    it '未ログインでは散歩を完了できないこと' do
      patch word_chain_walk_completion_path(word_chain_walk),
              params: { word_chain_walk: { finish_latitude: 35.681236, finish_longitude: 139.767125 } }
      expect(response).to redirect_to(root_path)
    end

    it '完了済みの散歩に再度完了リクエストした場合は更新せず、ホームへリダイレクトして完了済みメッセージを表示すること' do
      log_in(user)
      finished_word_chain_walk = FactoryBot.create( :word_chain_walk, user: user, start_char: 'り', finished_at: Time.current)

      expect do
        patch word_chain_walk_completion_path(finished_word_chain_walk),
                params: { word_chain_walk: { finish_latitude: 35.681236, finish_longitude: 139.767125 } }
      end.not_to change { finished_word_chain_walk.reload.finished_at }

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('すでに散歩は完了しています')
    end
  end
end
