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

  describe 'GET /word_chain_walks/:word_chain_walk_id/completion' do
    [ 0, 1, 2, 4 ].each do |count|
      it "#{count}件の記録を件数に合った説明と記録順の写真で表示する" do
        log_in(user)
        words = %w[りんご ごま まつ つき].first(count)
        words.each do |word|
          FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: word_chain_walk, word: word)
        end
        word_chain_walk.finish
        get word_chain_walk_completion_path(word_chain_walk)
        expect(response).to have_http_status(:ok)
        document = Nokogiri::HTML(response.body)
        if count.zero?
          expect(document.text).to include('今回は記録がありません')
        else
          expect(document.text).to include("#{count}個のことばを記録しました")
        end
        expect(document.css('.completion-photo-grid img').map { |image| image['alt'] }).to eq(
          words.first(3).map { |word| "「#{word}」の写真" }
        )
        expect(document.text).not_to include('たくさん')
        expect(document.text).not_to include('まで、ことばがつながりました') if count < 2
      end
    end
  end

  describe 'PATCH /word_chain_walks/:word_chain_walk_id/completion' do
    context "自分の進行中の散歩の場合" do
      it '任意のタイミングで完了できること' do
        log_in(user)
        expect do
          patch word_chain_walk_completion_path(word_chain_walk)
        end.to change { word_chain_walk.reload.finished? }.from(false).to(true)
      end

      it '任意で完了するとfinished_atが保存されること' do
        log_in(user)
        patch word_chain_walk_completion_path(word_chain_walk)
        expect(word_chain_walk.reload.finished_at).to be_present
      end

      it '任意で完了後に完了画面へリダイレクトされること' do
        log_in(user)
        patch word_chain_walk_completion_path(word_chain_walk)
        expect(response).to redirect_to(
          word_chain_walk_completion_path(word_chain_walk)
        )
      end
    end

    context "他人の散歩の場合" do
      it '任意のタイミングで完了できないこと' do
        log_in(user)
        expect do
          patch word_chain_walk_completion_path(other_word_chain_walk)
        end.not_to change { other_word_chain_walk.reload.finished_at }
      end

      it '任意完了しようとすると404になること' do
        log_in(user)
        patch word_chain_walk_completion_path(other_word_chain_walk)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "未ログインの場合" do
      it '任意での完了できないこと' do
        patch word_chain_walk_completion_path(word_chain_walk)
        expect(response).to redirect_to(root_path)
      end
    end

    context "完了済みの散歩の場合" do
      it '再度完了済みにしようとしても完了状態のままであること' do
        log_in(user)
        patch word_chain_walk_completion_path(finished_word_chain_walk)
        expect(finished_word_chain_walk.reload.finished?).to be true
      end

      it '再度完了済みにしようとした場合、すでに完了済みである旨のメッセージを表示すること' do
        log_in(user)

        finished_word_chain_walk =
          FactoryBot.create(
            :word_chain_walk,
            user: user,
            finished_at: 1.day.ago
          )

        patch word_chain_walk_completion_path(finished_word_chain_walk)

        expect(flash[:notice]).to eq('すでに散歩は完了しています。')
      end
    end
  end
end
