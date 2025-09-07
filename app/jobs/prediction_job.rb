# 推論用のリクエストをNuxt側から受け取って、FastAPI側に推論のリクエストを送る処理。
# RailsのActionJobで非同期に実行して推論が完了したら推論結果をprediction_logsテーブルに保存する。
class PredictionJob < ApplicationJob
  queue_as :default

  def perform(job_id:)
    require "net/http"
    require "uri"

    uri = URI.parse("http://host.docker.internal:8000")
    response = Net::HTTP.get_response(uri)

    data = JSON.parse(response.body)

    prediction_log = PredictionLog.find_by!(job_id: job_id)

    prediction_log.update!(answer: data["answer"], status: "completed")

    Rails.logger.info("[PredictionJob] job_id=#{job_id} code=#{response.code} body=#{response.body}")
  rescue => e
    Rails.logger.error("[PredictionJob] job_id=#{job_id} error=#{e.class} #{e.message}")
  end
end
