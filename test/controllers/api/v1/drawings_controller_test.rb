require "test_helper"

class Api::V1::DrawingsControllerTest < ActionDispatch::IntegrationTest
  test "#index MNISTデータの一覧情報を取得できる" do
    get api_v1_drawings_url
    assert_response :success
  end

  test "#create MNISTデータを作成できる" do
    file = fixture_file_upload("test_drawing.png", "image/png")

    assert_difference("Drawing.count", 1) do
      post api_v1_drawings_url, params: { label: 2, image: file }
    end

    assert_response :created
  end
end
