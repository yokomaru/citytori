require 'rails_helper'

RSpec.describe 'WordChainWalks::Completions', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  let(:word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
  end

  let(:other_word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: other_user, start_char: 'り')
  end

  let(:finished_word_chain_walk) do
    FactoryBot.create(
      :word_chain_walk,
      user: user,
      start_char: 'り',
      finished_at: Time.current
    )
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
    it '進行中の散歩を任意完了できること' do
      log_in(user)
      expect do
        patch word_chain_walk_completion_path(word_chain_walk)
      end.to change { word_chain_walk.reload.finished? }.from(false).to(true)
    end

    it '任意完了するとfinished_atが保存されること' do
      log_in(user)
      patch word_chain_walk_completion_path(word_chain_walk)
      expect(word_chain_walk.reload.finished_at).to be_present
    end

    it '任意完了後に完了画面へリダイレクトされること' do
      log_in(user)
      patch word_chain_walk_completion_path(word_chain_walk)
      expect(response).to redirect_to(
        word_chain_walk_completion_path(word_chain_walk)
      )
    end

    it '他人の散歩を任意完了できないこと' do
      log_in(user)
      expect do
        patch word_chain_walk_completion_path(other_word_chain_walk)
      end.not_to change { other_word_chain_walk.reload.finished_at }
    end

    it '他人の散歩を任意完了しようとすると404になること' do
      log_in(user)
      patch word_chain_walk_completion_path(other_word_chain_walk)
      expect(response).to have_http_status(:not_found)
    end

    it '未ログインでは任意完了できないこと' do
      patch word_chain_walk_completion_path(word_chain_walk)
      expect(response).to redirect_to(root_path)
    end

    it '完了済みの散歩に再完了リクエストしても完了状態のままであること' do
      log_in(user)
      patch word_chain_walk_completion_path(finished_word_chain_walk)
      expect(finished_word_chain_walk.reload.finished?).to be true
    end
  end
end
