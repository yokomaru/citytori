class ImageMetadataRemover
  def initialize(uploaded_image, content_type:)
    @uploaded_image = uploaded_image
    @content_type = content_type
  end

  def call
    output_format = { "image/jpeg" => "jpg", "image/png" => "png" }.fetch(@content_type)
    processed_file = ImageProcessing::Vips
      .source(@uploaded_image.tempfile)
      .convert(output_format)
      .saver(keep: "icc")
      .call

    basename = File.basename(@uploaded_image.original_filename, ".*")

    {
      io: processed_file,
      filename: "#{basename}.#{output_format}",
      content_type: output_format == "jpg" ? "image/jpeg" : "image/png"
    }
  end
end
