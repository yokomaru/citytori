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
        expect(response.body).to include(word_chain_walk_path(own_word_chain_walk))
        expect(response.body).not_to include(word_chain_walk_path(other_word_chain_walk))
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

      it '進行中の散歩がない場合は作成できること' do
        user = FactoryBot.create(:user)
        log_in(user)
        FactoryBot.create(:word_chain_walk, user: user, finished_at: Time.zone.now)

        expect do
          post word_chain_walks_path
        end.to change(WordChainWalk, :count)
        created_word_chain_walk = user.word_chain_walks.order(:id).last
        expect(response).to redirect_to(
          word_chain_walk_path(created_word_chain_walk)
        )
      end

      it '進行中の散歩がある場合は新規作成せずに進行中の散歩にリダイレクトすること' do
        user = FactoryBot.create(:user)
        log_in(user)
        FactoryBot.create(:word_chain_walk, user: user)

        expect do
          post word_chain_walks_path
        end.not_to change(WordChainWalk, :count)

        active_word_chain_walk = user.word_chain_walks.active.first
        expect(response).to redirect_to(
          word_chain_walk_path(active_word_chain_walk)
        )

        expect(flash[:alert]).to eq("進行中の散歩があります。新しい散歩を始めるには現在の散歩を終了してください。")
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

  describe 'GET /word_chain_walks/:id/map' do
    context '散歩が完了しているの場合' do
      it '散歩全体の地図が表示できる' do
        user = FactoryBot.create(:user)
        log_in(user)
        word_chain_walk = FactoryBot.create(:word_chain_walk, user: user)
        word_chain_walk.update!(finished_at: Time.current)
        get map_word_chain_walk_path(word_chain_walk)
        expect(response).to have_http_status(:ok)
      end
    end

    context '散歩が未完了の場合' do
      it '散歩全体の地図が表示できない' do
        user = FactoryBot.create(:user)
        log_in(user)
        word_chain_walk = FactoryBot.create(:word_chain_walk, user: user)
        get map_word_chain_walk_path(word_chain_walk)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /word_chain_walks/:id' do
    it 'しりとり散歩と紐づく記録を削除できる' do
      user = FactoryBot.create(:user)
      log_in(user)
      word_chain_walk = FactoryBot.create(:word_chain_walk, user: user)
      FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk)
      expect { delete word_chain_walk_path(word_chain_walk) }
        .to change(WordChainWalk, :count).by(-1)
        .and change(WordChainWalkStep, :count).by(-1)

      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(:see_other)
    end

    it "他のユーザーのしりとり散歩は削除できない" do
      other_user = FactoryBot.create(:user)
      word_chain_walk = FactoryBot.create(:word_chain_walk, user: other_user)
      user = FactoryBot.create(:user)
      log_in(user)

      expect {
        delete word_chain_walk_path(word_chain_walk)
      }.not_to change(WordChainWalk, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
