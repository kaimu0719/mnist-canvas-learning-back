class Api::V1::SamplesController < ApplicationController
  def create
    image_data = params[:image]
    label = params[:label]

    label = Integer(label) rescue nil
    return render json: { ok: false, error: 'label must be 0..9' }, status: :unprocessable_entity unless (0..9).include?(label)
    return render json: { ok: false, error: 'image data_url required' }, status: :unprocessable_entity if image_data.blank?

    png28 = ImagePreprocessor.from_data_url(image_data)

    # 保存先ディレクトリ
    dir = Rails.root.join('storage', 'samples', Time.zone.now.strftime('%Y%m%d'))
    FileUtils.mkdir_p(dir)

    # 一意なファイル名（label付き）
    filename = "#{Time.zone.now.strftime('%H%M%S')}_#{SecureRandom.hex(4)}_#{label}.png"
    path = dir.join(filename)

    File.binwrite(path, png28)

    sample = Sample.create!(label: label, path: path.to_s)

    render json: { ok: true, id: sample.id, path: sample.path }

  rescue => e
    Rails.logger.error e.full_message
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end
end