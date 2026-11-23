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

  def attached_image
    fixture_file_upload(
      Rails.root.join('spec/fixtures/files/480x320.png'),
      'image/png'
    )
  end

  def metadata_image
    fixture_file_upload(
      Rails.root.join('spec/fixtures/files/test_metadata.jpg'),
      'image/jpeg'
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
    context '有効な記録を登録する場合' do
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

      it '保存された添付元からメタデータ(Exif、GPS情報)が削除されていること' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: {
                 word_chain_walk_step: {
                   word: 'りんご',
                   memo: '赤いりんご',
                   image: metadata_image
                 }
               }
        end.to change(word_chain_walk.word_chain_walk_steps, :count).by(1)

        step = word_chain_walk.word_chain_walk_steps.order(:id).last
        image = Vips::Image.new_from_buffer(step.image.download, '')

        expect(image.get_fields.grep(/gps/i)).to be_empty
        expect(image.get_fields.grep(/exif/i)).to be_empty
      end

      it 'PNG画像をJPEGの拡張子で送ってもPNGとして保存されること' do
        log_in(user)
        image = Rack::Test::UploadedFile.new(
          Rails.root.join('spec/fixtures/files/transparent.png'),
          'image/jpeg',
          original_filename: 'transparent.jpg'
        )

        post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
             params: {
               word_chain_walk_step: {
                 word: 'りんご',
                 memo: '透過PNG',
                 image: image
               }
             }

        step = word_chain_walk.word_chain_walk_steps.order(:id).last
        image = Vips::Image.new_from_buffer(step.image.download, '')

        expect(step.image.blob.content_type).to eq('image/png')
        expect(image.bands).to eq(4)
      end
    end

    context "無効な記録を登録する場合" do
      it '記録が追加されないこと' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: invalid_step_params
        end.not_to change(WordChainWalkStep, :count)
      end

      it 'バリデーションエラー時はステータス422が返却されること' do
        log_in(user)

        post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
             params: invalid_step_params

        expect(response).to have_http_status(:unprocessable_content)
      end

      it '画像がない場合は422を返すこと' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
              params: {
                word_chain_walk_step: {
                  word: 'りんご',
                  memo: '赤いりんご'
                }
              }
        end.not_to change(WordChainWalkStep, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it '加工前のサイズが上限を超える場合は加工せず422を返すこと' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: {
                 word_chain_walk_step: {
                   word: 'りんご',
                   memo: '赤いりんご',
                   image: fixture_file_upload(
                     Rails.root.join('spec/fixtures/files/11MB.png'),
                     'image/png'
                   )
                 }
               }
        end.not_to change(WordChainWalkStep, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it '画像加工に失敗した場合は422を返し、記録を保存しないこと' do
        log_in(user)
        remover = instance_double(ImageMetadataRemover)
        allow(ImageMetadataRemover).to receive(:new).and_return(remover)
        allow(remover).to receive(:call).and_raise(Vips::Error)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
               params: {
                 word_chain_walk_step: {
                   word: 'りんご',
                   memo: '赤いりんご',
                   image: metadata_image
                 }
               }
        end.not_to change(WordChainWalkStep, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('画像を処理できませんでした')
      end
    end

    it 'WebPの実体をJPEGとして送っても登録できないこと' do
      log_in(user)

      expect do
        post word_chain_walk_word_chain_walk_steps_path(word_chain_walk),
            params: {
              word_chain_walk_step: {
                word: 'りんご',
                memo: 'WebPテスト',
                image: Rack::Test::UploadedFile.new(
                  Rails.root.join('app/assets/images/walk-example.webp'),
                  'image/jpeg',
                  original_filename: 'webp.jpg'
                )
              }
            }
      end.not_to change(WordChainWalkStep, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end


    context "他人の散歩の場合" do
      it '記録を追加できないこと' do
        log_in(user)

        expect do
          post word_chain_walk_word_chain_walk_steps_path(other_word_chain_walk),
              params: valid_step_params
        end.not_to change(WordChainWalkStep, :count)
      end

      it '記録を追加しようとした場合は404になること' do
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
    context "進行中の散歩に記録がある場合" do
      it "直前の記録を削除できること" do
        log_in(user)

        FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "りんご")
        FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "ごりら")

        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
        end.to change(WordChainWalkStep, :count).by(-1)
      end

      it "直前の記録だけが削除されること" do
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
    end

    context "記録がない場合" do
      it "エラーにならずに削除がされないこと" do
        log_in(user)

        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
        end.not_to change(WordChainWalkStep, :count)
      end
    end

    context "他人の散歩の場合" do
      it "記録が削除できないこと" do
        log_in(user)

        FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: other_word_chain_walk, word: "りんご")

        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(other_word_chain_walk)
        end.not_to change(WordChainWalkStep, :count)
      end
    end

    context "完了済みの散歩の場合" do
      it "完了済みの散歩ではStepを削除できないこと" do
        log_in(user)

        FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: "りんご")

        word_chain_walk.update!(finished_at: Time.current)

        expect do
          delete latest_word_chain_walk_word_chain_walk_steps_path(word_chain_walk)
        end.not_to change(WordChainWalkStep, :count)
      end
    end
  end

  describe 'PUTS /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/:id' do
    it '自分のStep詳細のメモを更新できること' do
      word_chain_walk_step = create_word_chain_walk_step(word_chain_walk)

      log_in(user)

      expect do
        patch word_chain_walk_word_chain_walk_step_path(word_chain_walk, word_chain_walk_step), params: { word_chain_walk_step: { memo: "更新したメモ" } }
      end.to change { word_chain_walk_step.reload.memo }
          .from("赤いりんご")
          .to("更新したメモ")

      expect(response).to have_http_status(:see_other)

      expect(response).to redirect_to(word_chain_walk_word_chain_walk_step_path(word_chain_walk, word_chain_walk_step))
    end

    it '他人のStep詳細をメモを更新できないこと' do
      other_word_chain_walk_step = create_word_chain_walk_step(other_word_chain_walk)

      log_in(user)

      expect do
        patch word_chain_walk_word_chain_walk_step_path(other_word_chain_walk, other_word_chain_walk_step), params: { word_chain_walk_step: { memo: "更新したメモ" } }
      end.not_to change { other_word_chain_walk_step.reload.memo }

      expect(response).to have_http_status(:not_found)
    end
  end
end
