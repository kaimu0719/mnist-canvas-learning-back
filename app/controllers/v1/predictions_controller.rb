class V1::PredictionsController < ApplicationController
  # MNISTデータを保存し推論を開始する
  def create
    user = User.first

    drawing = user.drawings.build(label: normalize_label(drawing_params[:label]))
    if drawing_params[:image].present?
      drawing.image.attach(drawing_params[:image])
    end

    if drawing.save == false
      return render :errors, status: :unprocessable_entity, locals: { record: drawing }
    end

    job_id = SecureRandom.uuid
    @prediction_log = PredictionLog.create(drawing_id: drawing.id, job_id: job_id, status: "pending")
    PredictionJob.perform_later(job_id: job_id)

    render :show, status: :created, locals: { prediction_log: @prediction_log }
  end

  def show
    @prediction_log = PredictionLog.find(params[:id])
  end

  private
    def drawing_params
      params.permit(:image, :label)
    end

    def normalize_label(label)
      return nil if label == "null"
      Integer(label)
    end
end
