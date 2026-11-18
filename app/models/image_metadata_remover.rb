class ImageMetadataRemover
  def initialize(uploaded_image)
    @uploaded_image = uploaded_image
  end

  def call
    processed_file = ImageProcessing::Vips
      .source(@uploaded_image.tempfile)
      .saver(keep: "icc")
      .call

    {
      io: processed_file,
      filename: @uploaded_image.original_filename,
      content_type: @uploaded_image.content_type
    }
  end
end
