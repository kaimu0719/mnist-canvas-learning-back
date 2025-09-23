# 推論用のリクエストをNuxt側から受け取って、FastAPI側に推論のリクエストを送る処理。
# 推論が完了したら推論結果をprediction_logsテーブルに保存する。
class PredictionJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  RETRIES = 3

  def perform(job_id:)
    require "net/http"
    require "uri"
    require "json"

    prediction_log = PredictionLog.find_by!(job_id: job_id)
    drawing = prediction_log.drawing

    unless drawing.image.attached?
      prediction_log.update(status: "failed")
      Rails.logger.error("[PredictionJob] job_id=#{job_id} error=NoImageAttached")
      return
    end

    app_uri = URI.parse(AppConstants::APP_URL)
    host_with_port =
      if app_uri.port && ![ 80, 443 ].include?(app_uri.port)
        "#{app_uri.host}:#{app_uri.port}"
      else
        app_uri.host
      end

    image_url = rails_blob_url(
      drawing.image,
      disposition: "attachment",
      host: host_with_port,
      protocol: app_uri.scheme
    )

    ai_base = AppConstants::AI_BASE_URL
    raise "FASTAPI base must start with https://" unless ai_base.start_with?("https://")

    uri = URI.join(ai_base, "/predict")

    tries = 0
    begin
      tries += 1

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      # 証明書検証（デフォルトで有効だが明示）
      http.open_timeout = 10
      http.read_timeout  = 30

      req = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/json")
      req.body = { image_url: image_url }.to_json

      Rails.logger.info("[PredictionJob] POST #{uri} body=#{req.body}")
      res = http.request(req)
      Rails.logger.info("[PredictionJob] RES code=#{res.code} ctype=#{res["content-type"]} len=#{res.body&.bytesize}")

      if res.is_a?(Net::HTTPSuccess)
        # 成功時のみ JSON を読む
        data =
          if res["content-type"].to_s.include?("json")
            JSON.parse(res.body)
          else
            JSON.parse(res.body) rescue {}
          end
        prediction_log.update!(answer: data["answer"], status: "completed")
        Rails.logger.info("[PredictionJob] job_id=#{job_id} completed answer=#{data["answer"].inspect}")
      else
        # 4xx/5xx はエラー扱い（本文はログに残すが parse はしない）
        Rails.logger.error("[PredictionJob] job_id=#{job_id} http_error status=#{res.code} body=#{res.body&.slice(0, 500)}")
        raise "FastAPI error status=#{res.code}"
      end

    rescue => e
      Rails.logger.error("[PredictionJob] job_id=#{job_id} try=#{tries} error=#{e.class} #{e.message}")
      if tries < RETRIES
        sleep (0.2 * (2 ** (tries - 1)))
        retry
      else
        prediction_log.update(status: "failed")
        raise
      end
    end
  end
end
