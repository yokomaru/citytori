require 'rails_helper'

RSpec.describe 'WordChainWalkSteps', type: :request do
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

  describe 'GET /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/new' do
    it '自分の散歩のStep追加画面を表示できること' do
      user = FactoryBot.create(:user)
      word_chain_walk = FactoryBot.create(:word_chain_walk, user: user)
      log_in(user)
      get new_word_chain_walk_word_chain_walk_step_path(word_chain_walk)
      expect(response).to have_http_status(:ok)
    end

    it '他人の散歩のStep追加画面を表示できないこと' do
      user = FactoryBot.create(:user)
      other_user = FactoryBot.create(:user)
      other_word_chain_walk =
        FactoryBot.create(:word_chain_walk, user: other_user)

      log_in(user)

      get new_word_chain_walk_word_chain_walk_step_path(other_word_chain_walk)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps' do
    context 'ステップを登録する場合' do
      it '自分の散歩にStepを追加できること' do
        user = FactoryBot.create(:user)
        word_chain_walk =
          FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
        log_in(user)
        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: {
                 word_chain_walk_step: {
                   word: 'りんご',
                   memo: '赤いりんご',
                   image: fixture_file_upload(
                     Rails.root.join('spec/fixtures/files/480x320.png'),
                     'image/png'
                   )
                 }
               }
        end.to change(word_chain_walk.word_chain_walk_steps, :count).by(1)
        expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
      end

      it 'バリデーションエラー時は422で再表示されること' do
        user = FactoryBot.create(:user)
        word_chain_walk =
          FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
        log_in(user)
        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: {
                 word_chain_walk_step: {
                   word: nil,
                   memo: '赤いりんご',
                   image: fixture_file_upload(
                     Rails.root.join('spec/fixtures/files/480x320.png'),
                     'image/png'
                   )
                 }
               }
        end.not_to change(WordChainWalkStep, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it '他人の散歩にはStepを追加できないこと' do
        user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        other_word_chain_walk =
          FactoryBot.create(
            :word_chain_walk,
            user: other_user,
            start_char: 'り'
          )
        log_in(user)
        expect do
          post word_chain_walk_word_chain_walk_steps_path(other_word_chain_walk),
               params: {
                 word_chain_walk_step: {
                   word: 'りんご',
                   memo: '赤いりんご',
                   image: fixture_file_upload(
                     Rails.root.join('spec/fixtures/files/480x320.png'),
                     'image/png'
                   )
                 }
               }
        end.not_to change(WordChainWalkStep, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/:id' do
    it '自分のStep詳細を表示できること' do
      user = FactoryBot.create(:user)
      word_chain_walk =
        FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
      word_chain_walk_step =
        FactoryBot.create(
          :word_chain_walk_step,
          :with_image,
          word_chain_walk: word_chain_walk,
          word: 'りんご',
          memo: '赤いりんご'
        )
      log_in(user)
      get word_chain_walk_word_chain_walk_step_path(
        word_chain_walk,
        word_chain_walk_step
      )
      expect(response).to have_http_status(:ok)
    end

    it '他人のStep詳細を表示できないこと' do
      user = FactoryBot.create(:user)
      other_user = FactoryBot.create(:user)
      other_word_chain_walk =
        FactoryBot.create(
          :word_chain_walk,
          user: other_user,
          start_char: 'り'
        )
      other_word_chain_walk_step =
        FactoryBot.create(
          :word_chain_walk_step,
          :with_image,
          word_chain_walk: other_word_chain_walk,
          word: 'りんご'
        )
      log_in(user)
      get word_chain_walk_word_chain_walk_step_path(
        other_word_chain_walk,
        other_word_chain_walk_step
      )
      expect(response).to have_http_status(:not_found)
    end
  end
end
