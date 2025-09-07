class V1::PredictionsController < ApplicationController
  # MNISTデータを保存し推論を開始する
  def create
    user = User.first

    drawing = user.drawings.build(label: params[:label])
    if params[:image].present?
      drawing.image.attach(params[:image])
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
end
