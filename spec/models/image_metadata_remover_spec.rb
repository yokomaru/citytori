require 'rails_helper'

RSpec.describe ImageMetadataRemover do
  let(:uploaded_image) do
    fixture_file_upload(
      Rails.root.join('spec/fixtures/files/test_metadata.jpg'),
      'image/jpeg'
    )
  end

  describe '#call' do
    let(:content_type) { uploaded_image.content_type }
    let(:result) { described_class.new(uploaded_image, content_type: content_type).call }

    it 'Active Storageに添付できるハッシュを返すこと' do
      expect(result).to include(:io, :filename, :content_type)
      expect(result[:filename]).to eq('test_metadata.jpg')
      expect(result[:content_type]).to eq('image/jpeg')
    end

    it 'ExifとGPS情報が削除され、ICCプロファイルが保持されていること' do
      result[:io].rewind
      image = Vips::Image.new_from_buffer(result[:io].read, '')
      original_image = Vips::Image.new_from_file(uploaded_image.tempfile.path)

      expect(image.get_fields.grep(/gps/i)).to be_empty
      expect(image.get_fields.grep(/exif/i)).to be_empty
      expect(image.get_fields).to include('icc-profile-data')
      expect(image.get('icc-profile-data')).to eq(original_image.get('icc-profile-data'))
    end

    context 'Orientation情報を含む画像の場合' do
      let(:uploaded_image) do
        fixture_file_upload(
          Rails.root.join('spec/fixtures/files/orientation-6.jpg'),
          'image/jpeg'
        )
      end

      it 'Orientationに従って画素の向きが補正されること' do
        result[:io].rewind
        image = Vips::Image.new_from_buffer(result[:io].read, '')

        expect(image.width).to eq(800)
        expect(image.height).to eq(600)
        expect(image.get_fields.grep(/orientation/i)).to be_empty
      end
    end

    context '透過PNGの場合' do
      let(:uploaded_image) do
        fixture_file_upload(
          Rails.root.join('spec/fixtures/files/transparent.png'),
          'image/png'
        )
      end

      it '透過情報が保持されること' do
        result[:io].rewind
        image = Vips::Image.new_from_buffer(result[:io].read, '')

        expect(image.bands).to eq(4)
      end
    end

    context 'PNGの実体と拡張子が異なる場合' do
      let(:content_type) { 'image/png' }

      let(:uploaded_image) do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec/fixtures/files/transparent.png'),
          'image/jpeg',
          original_filename: 'transparent.jpg'
        )
      end

      it 'PNG形式と透過情報が保持されること' do
        result[:io].rewind
        image = Vips::Image.new_from_buffer(result[:io].read, '')

        expect(result[:filename]).to eq('transparent.png')
        expect(result[:content_type]).to eq('image/png')
        expect(image.bands).to eq(4)
      end
    end
  end
end
