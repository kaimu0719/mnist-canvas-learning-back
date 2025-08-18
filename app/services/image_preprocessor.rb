class ImagePreprocessor
  TARGET = 28

  # 入力: "data:image/png;base64,...."
  # 出力: { png28: String(PNGバイナリ), vector: Array<Float> 28*28(0..1) }
  def self.from_data_url(data_url)
    base64 = data_url.to_s.split(',')[1]
    raise ArgumentError, 'invalid data url' unless base64

    bin = Base64.decode64(base64)
    img = MiniMagick::Image.read(bin)

    img.colorspace 'Gray'
    img.resize "#{TARGET}x#{TARGET}!"

    png28 = img.to_blob

    png28
  end
end
