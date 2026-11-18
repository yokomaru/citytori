require 'rails_helper'

RSpec.describe 'WordChainWalkStepImages', type: :request do
  let(:user) { FactoryBot.create(:user) }

  let(:word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: user, start_char: 'あ')
  end

  let(:other_word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: FactoryBot.create(:user), start_char: 'あ')
  end

  let(:word_chain_walk_step) do
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk)
  end

  let(:other_word_chain_walk_step) do
    FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: other_word_chain_walk)
  end

  describe 'GET /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/:id/image' do
    context 'ログインしている場合' do
      it 'thumbnailを取得できること' do
        log_in(user)

        get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: :thumbnail)

        expect(response).to have_http_status(:redirect)
      end

      it 'cardを取得できること' do
        log_in(user)

        get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: :card)

        expect(response).to have_http_status(:redirect)
      end

      it 'detailを取得できること' do
        log_in(user)

        get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: :detail)

        expect(response).to have_http_status(:redirect)
      end

      it 'summaryを取得できること' do
        log_in(user)

        get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: :summary)

        expect(response).to have_http_status(:redirect)
      end

      it 'バリアントが指定されていない場合は404を返すこと' do
        log_in(user)

        get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step)

        expect(response).to have_http_status(:not_found)
      end

      it '許可されていないバリアントは404を返すこと' do
        log_in(user)

        get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: 'test')

        expect(response).to have_http_status(:not_found)
      end

      it '他ユーザーの記録は取得できないこと' do
        log_in(user)

        get word_chain_walk_word_chain_walk_step_image_path(other_word_chain_walk, other_word_chain_walk_step, variant: 'card')

        expect(response).to have_http_status(:not_found)
      end

      it '発行から1分以内の場合は署名付きURLは取得できること' do
        log_in(user)

        travel_to Time.zone.local(2026, 11, 18, 12, 0, 0) do
          get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: 'card')
          redirect_image_url = response.location

          travel 59.seconds
          get URI.parse(redirect_image_url).request_uri

          expect(response).to have_http_status(:ok)
        end
      end

      it '発行から1分を過ぎた場合は署名付きURLは取得できないこと' do
        log_in(user)

        travel_to Time.zone.local(2026, 11, 18, 12, 0, 0) do
          get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: 'card')
          redirect_image_url = response.location

          travel 61.seconds
          get URI.parse(redirect_image_url).request_uri

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'ログインしていない場合' do
      it '画像を取得できないこと' do
        get word_chain_walk_word_chain_walk_step_image_path(word_chain_walk, word_chain_walk_step, variant: 'card')

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
