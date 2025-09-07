require "test_helper"

class V1::PredictionsControllerTest < ActionDispatch::IntegrationTest
  test "#create MNISTデータを作成して推論を開始する" do
    file = fixture_file_upload("test_drawing.png", "image/png")

    assert_enqueued_with(job: PredictionJob) do
      assert_difference([ "Drawing.count", "PredictionLog.count" ], +1) do
        post v1_predictions_url, params: { label: 2, image: file }, as: :json
      end
    end

    assert_response :created
  end

  test "#show 推論結果の詳細を取得できる" do
    get v1_prediction_url(prediction_logs(:status_pending_answer_0)), as: :json
    assert_response :success
  end
end
