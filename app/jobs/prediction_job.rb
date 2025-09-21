# 推論用のリクエストをNuxt側から受け取って、FastAPI側に推論のリクエストを送る処理。
# 推論が完了したら推論結果をprediction_logsテーブルに保存する。
class PredictionJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  def perform(job_id:)
    require "net/http"
    require "uri"
    require "json"

    prediction_log = PredictionLog.find_by!(job_id: job_id)
    drawing = prediction_log.drawing

    if drawing.image.attached? == false
      prediction_log.update(status: "failed")
      Rails.logger.error("[PredictionJob] job_id=#{job_id} error=NoImageAttached")
      return
    end

    app_uri = URI.parse(ENV["APP_URL"])

    host_with_port =
      if app_uri.port && ![ 80, 443 ].include?(app_uri.port)
        "#{app_uri.host}:#{app_uri.port}"
      else
        app_uri.host
      end

    # 署名付きURL
    image_url = rails_blob_url(drawing.image, disposition: "attachment", host: host_with_port, protocol: app_uri.scheme)

    uri = URI.join(ENV["AI_BASE_URL"], "/predict")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 30
    request = Net::HTTP::Post.new(uri.request_uri, { "Content-Type" => "application/json" })
    request.body = {
      image_url: image_url
    }.to_json

    Rails.logger.info("[PredictionJob] POST #{uri} body=#{request.body}")
    response = http.request(request)
    Rails.logger.info("[PredictionJob] RES code=#{response.code} len=#{response.body&.bytesize}")
    data = JSON.parse(response.body)

    prediction_log.update!(answer: data["answer"], status: "completed")

    Rails.logger.info("[PredictionJob] job_id=#{job_id} code=#{response.code} body=#{response.body}")
  rescue => e
    Rails.logger.error("[PredictionJob] job_id=#{job_id} error=#{e.class} #{e.message}")
  end
end
