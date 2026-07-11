require 'rails_helper'

RSpec.describe 'WordChainWalks', type: :request do
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

  describe 'GET /word_chain_walks' do
    context 'ログインしている場合' do
      it '一覧を表示できること' do
        user = FactoryBot.create(:user)
        log_in(user)
        get word_chain_walks_path
        expect(response).to have_http_status(:ok)
      end

      it '自分の散歩のみ表示されること' do
        user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        own_word_chain_walk =
          FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
        other_word_chain_walk =
          FactoryBot.create(:word_chain_walk, user: other_user, start_char: 'あ')
        log_in(user)
        get word_chain_walks_path
        expect(response.body).to include(own_word_chain_walk.start_char)
        expect(response.body).not_to include(other_word_chain_walk.start_char)
      end
    end

    context 'ログインしていない場合' do
      it '一覧を表示できないこと' do
        get word_chain_walks_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /word_chain_walks' do
    context 'ログインしている場合' do
      it 'ログインユーザーに紐づく散歩を作成できること' do
        user = FactoryBot.create(:user)
        log_in(user)
        expect do
          post word_chain_walks_path
        end.to change(user.word_chain_walks, :count).by(1)
        created_word_chain_walk = user.word_chain_walks.order(:id).last
        expect(created_word_chain_walk.start_char).to be_present
        expect(created_word_chain_walk.started_at).to be_present
        expect(response).to redirect_to(
          word_chain_walk_path(created_word_chain_walk)
        )
      end
    end

    context 'ログインしていない場合' do
      it '散歩を作成できないこと' do
        expect do
          post word_chain_walks_path
        end.not_to change(WordChainWalk, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /word_chain_walks/:id' do
    context 'ログインしている場合' do
      it '自分の散歩詳細を表示できること' do
        user = FactoryBot.create(:user)
        word_chain_walk = FactoryBot.create(:word_chain_walk, user: user)
        log_in(user)
        get word_chain_walk_path(word_chain_walk)
        expect(response).to have_http_status(:ok)
      end

      it '他人の散歩詳細を表示できないこと' do
        user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        other_word_chain_walk = FactoryBot.create(:word_chain_walk, user: other_user)
        log_in(user)
        get word_chain_walk_path(other_word_chain_walk)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'ログインしていない場合' do
      it '散歩詳細を表示できないこと' do
        user = FactoryBot.create(:user)
        word_chain_walk = FactoryBot.create(:word_chain_walk, user: user)
        get word_chain_walk_path(word_chain_walk)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
