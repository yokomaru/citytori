require "rails_helper"

RSpec.describe "Walk interaction checks", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider, uid: user.uid,
      info: { email: user.email, name: user.name }
    )
    visit "/auth/google_oauth2/callback"
  end

  scenario "地図から詳細へ進み、選択した記録のある地図へ戻る" do
    walk = FactoryBot.create(:word_chain_walk, user: user)
    step = FactoryBot.create(:word_chain_walk_step, :with_image, word_chain_walk: walk,
                             latitude: 35.68, longitude: 139.76)
    walk.update!(finished_at: Time.current)
    visit map_word_chain_walk_path(walk)
    find(".walk-map-record[data-step-id='#{step.id}']").click
    within "#selected_walk_step" do
      expect(page).to have_css("h2", text: step.word)
      find("a.walk-record-card").click
    end
    expect(page).to have_css("h1", text: step.word)
    find(".walk-step-detail-back a").click
    expect(page).to have_css("#selected_walk_step h2", text: step.word)
    expect(page).to have_css(".walk-map-record[data-step-id='#{step.id}'][aria-current='true']")
    expect(page).to have_css(".walk-map-marker[data-step-id='#{step.id}'][aria-current='true']")
  end

  scenario "位置情報が拒否されても写真とことばを保存できる" do
    walk = FactoryBot.create(:word_chain_walk, user: user, start_char: "り")
    visit word_chain_walk_path(walk)
    page.execute_script(<<~JS)
      navigator.geolocation.getCurrentPosition = (_success, failure) => {
        failure({ code: 1, message: "Permission denied for test" });
      };
    JS
    attach_file("word_chain_walk_step_image", Rails.root.join("spec/fixtures/files/480x320.png"), make_visible: true)
    within "dialog[open]" do
      expect(page).to have_text("位置情報なしで記録します。")
      fill_in "見つけたことば", with: "りんご"
      fill_in "メモ", with: "テスト用の記録"
      click_button "写真とことばを記録する"
    end
    expect(page).to have_css("#latest_step", text: "りんご")
    saved = walk.word_chain_walk_steps.last
    expect(saved.image).to be_attached
    expect(saved.memo).to eq("テスト用の記録")
    expect(saved.latitude).to be_nil
    expect(saved.longitude).to be_nil
  end

  scenario "削除確認のキャンセルでは残り、承認したテスト用の散歩だけ削除する" do
    walk = FactoryBot.create(:word_chain_walk, user: user, finished_at: Time.current)
    visit word_chain_walk_path(walk)
    dismiss_confirm("この散歩を削除しますか？") { click_button "この散歩を削除する" }
    expect(page).to have_css("h1", text: "散歩の記録")
    expect(WordChainWalk.exists?(walk.id)).to be(true)
    accept_confirm("この散歩を削除しますか？") { click_button "この散歩を削除する" }
    expect(page).to have_text("しりとり散歩を削除しました。")
    expect(WordChainWalk.exists?(walk.id)).to be(false)
  end
end
