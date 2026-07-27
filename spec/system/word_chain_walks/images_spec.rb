require 'rails_helper'

RSpec.describe 'Images', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { FactoryBot.create(:user) }
  let(:word_chain_walk) { FactoryBot.create(:word_chain_walk, user: user, start_char: 'り') }

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

    visit '/auth/google_oauth2/callback'
  end

  scenario '画像を選択するとプレビューが表示されること' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css(
      '[data-previews-target="preview"].hidden',
      visible: :all
    )

    attach_file(
      'word_chain_walk_step_image',
      Rails.root.join('spec/fixtures/files/480x320.png'),
      make_visible: true
    )

    within 'dialog[data-modal-target="modal"][open]' do
      expect(page).to have_css(
        '[data-previews-target="preview"]:not(.hidden)'
      )

      expect(
        find('[data-previews-target="image"]')[:src]
      ).to start_with('blob:')
    end
  end

  scenario '10MBを超える画像を選択するとプレビューが表示されないこと' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css(
      '[data-previews-target="preview"].hidden',
      visible: :all
    )

    file_input = find(
      '#word_chain_walk_step_image',
      visible: :all
    )

    accept_alert('画像のサイズは10MB以下にしてください') do
      file_input.attach_file(
        Rails.root.join('spec/fixtures/files/11MB.png')
      )
    end

    expect(page).to have_css(
      '[data-previews-target="preview"].hidden',
      visible: :all
    )

    expect(
      find('[data-previews-target="image"]', visible: :all)[:src]
    ).to be_blank
  end

  scenario 'PNG、JPEG以外のファイルを選択するとプレビューが表示されないこと' do
    log_in(user)
    visit word_chain_walk_path(word_chain_walk)

    expect(page).to have_css(
      '[data-previews-target="preview"].hidden',
      visible: :all
    )

    file_input = find(
      '#word_chain_walk_step_image',
      visible: :all
    )

    accept_alert('PNGまたはJPEG形式のファイルを選択してください') do
      file_input.attach_file(
        Rails.root.join('spec/fixtures/files/test_pdf.pdf')
      )
    end

    expect(page).to have_css(
      '[data-previews-target="preview"].hidden',
      visible: :all
    )

    expect(
      find('[data-previews-target="image"]', visible: :all)[:src]
    ).to be_blank
  end
end
