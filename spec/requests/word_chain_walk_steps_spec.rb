require 'rails_helper'

RSpec.describe 'WordChainWalkSteps', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  let(:word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: user, start_char: 'り')
  end

  let(:other_word_chain_walk) do
    FactoryBot.create(:word_chain_walk, user: other_user, start_char: 'り')
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

  def attached_image
    fixture_file_upload(
      Rails.root.join('spec/fixtures/files/480x320.png'),
      'image/png'
    )
  end

  def valid_step_params
    {
      word_chain_walk_step: {
        word: 'りんご',
        memo: '赤いりんご',
        image: attached_image
      }
    }
  end

  def invalid_step_params
    {
      word_chain_walk_step: {
        word: nil,
        memo: '赤いりんご',
        image: attached_image
      }
    }
  end

  def create_word_chain_walk_step(word_chain_walk)
    FactoryBot.create(
      :word_chain_walk_step,
      :with_image,
      word_chain_walk: word_chain_walk,
      word: 'りんご',
      memo: '赤いりんご'
    )
  end

  describe 'POST /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps' do
    context 'ステップを登録する場合' do
      it '自分の散歩にStepを追加できること' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: valid_step_params
        end.to change(word_chain_walk.word_chain_walk_steps, :count).by(1)
      end

      it 'Step追加後に散歩詳細へリダイレクトされること' do
        log_in(user)

        post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
             params: valid_step_params

        expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
      end

      it 'バリデーションエラー時はStepを追加しないこと' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: invalid_step_params
        end.not_to change(WordChainWalkStep, :count)
      end

      it 'バリデーションエラー時は422で再表示されること' do
        log_in(user)

        post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
             params: invalid_step_params

        expect(response).to have_http_status(:unprocessable_content)
      end

      it '他人の散歩にはStepを追加できないこと' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(other_word_chain_walk),
               params: valid_step_params
        end.not_to change(WordChainWalkStep, :count)
      end

      it '他人の散歩にStep追加しようとした場合は404になること' do
        log_in(user)

        post word_chain_walk_word_chain_walk_steps_path(other_word_chain_walk),
             params: valid_step_params

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'んで終わる単語を追加した時' do
      before do
        log_in(user)
        post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
             params: {
               word_chain_walk_step: {
                 word: 'りん',
                 image: attached_image
               }
             }
      end

      it 'finished_atが保存されること' do
        expect(word_chain_walk.reload.finished_at).to be_present
      end

      it '完了画面へリダイレクトされること' do
        expect(response).to redirect_to(word_chain_walk_completion_path(word_chain_walk))
      end
    end
  end

  describe 'GET /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/:id' do
    it '自分のStep詳細を表示できること' do
      word_chain_walk_step = create_word_chain_walk_step(word_chain_walk)

      log_in(user)

      get word_chain_walk_word_chain_walk_step_path(
        word_chain_walk,
        word_chain_walk_step
      )

      expect(response).to have_http_status(:ok)
    end

    it '他人のStep詳細を表示できないこと' do
      other_word_chain_walk_step =
        create_word_chain_walk_step(other_word_chain_walk)

      log_in(user)

      get word_chain_walk_word_chain_walk_step_path(
        other_word_chain_walk,
        other_word_chain_walk_step
      )

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/latest" do
    it "最新Stepを削除できること" do
      log_in(user)

      FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "りんご")
      FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "ごりら")

      expect do
        delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
      end.to change(WordChainWalkStep, :count).by(-1)
    end

    it "最新Stepだけが削除されること" do
      log_in(user)

      old_step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "りんご")
      latest_step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "ごりら")

      delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)

      expect(WordChainWalkStep.exists?(old_step.id)).to be true
      expect(WordChainWalkStep.exists?(latest_step.id)).to be false
    end

    it "削除後に散歩詳細画面へリダイレクトされること" do
      log_in(user)

      FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "りんご")

      delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)

      expect(response).to redirect_to(word_chain_walk_path(word_chain_walk))
    end

    it "Stepがない場合でもエラーにならないこと" do
      log_in(user)

      expect do
        delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
      end.not_to change(WordChainWalkStep, :count)
    end

    it "他人の散歩のStepを削除できないこと" do
      log_in(user)

      FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: other_word_chain_walk, word: "りんご")

      expect do
        delete latest_word_chain_walk_word_chain_walk_steps_path(other_word_chain_walk)
      end.not_to change(WordChainWalkStep, :count)
    end

    it "完了済みの散歩ではStepを削除できないこと" do
      log_in(user)

      FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "りんご")

      word_chain_walk.update!(finished_at: Time.current)

      expect do
        delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
      end.not_to change(WordChainWalkStep, :count)
    end
  end

  describe 'image size validation' do
    it '10MB以下の画像は有効である' do
      step = FactoryBot.build(:word_chain_walk_step)

      step.image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/480x320.png')),
        filename: '480x320.png',
        content_type: 'image/png'
      )

      expect(step).to be_valid
    end

    it '10MBを超える画像は無効であること' do
      file = Tempfile.new([ 'large_image', '.png' ])
      file.truncate(10.megabytes + 1)
      file.rewind

      step = FactoryBot.build(:word_chain_walk_step)

      step.image.attach(
        io: file,
        filename: 'large_image.png',
        content_type: 'image/png'
      )

      expect(step).to be_invalid
      expect(step.errors[:image]).to include('は10MB以下にしてください')
    ensure
      file&.close!
    end
  end
end
