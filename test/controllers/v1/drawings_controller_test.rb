require "test_helper"

class V1::DrawingsControllerTest < ActionDispatch::IntegrationTest
  test "#index MNISTデータの一覧情報を取得できる" do
    get v1_drawings_url, as: :json
    assert_response :success
  end

  test "#create MNISTデータを作成できる" do
    file = fixture_file_upload("test_drawing.png", "image/png")

    assert_difference("Drawing.count", 1) do
      post v1_drawings_url, params: { label: 2, image: file }, as: :json
    end

    assert_response :created
  end

  test "#show MNISTデータの詳細を取得できる" do
    get v1_drawing_url(drawings(:drawing_of_label_0)), as: :json
    assert_response :success
  end
end
